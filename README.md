# セキュア IaC テンプレート（Terraform / GitHub Actions / Snowflake）— 本番運用向け 詳細 README

このテンプレートは **本番運用**を前提に、変更管理・セキュリティ・コスト・供給鎖（Supply Chain）を総合的にカバーします。  
ブートストラップと本運用を厳格に分離し、環境境界（Dev/Stg/Prod）を **GitHub Environments + OIDC 条件**で強制します。

- 最終更新日: 2025-08-19
- 対応クラウド: AWS / Snowflake
- IaC: Terraform 1.8 系
- CI: GitHub Actions（OIDC）

---

## 目次
1. [全体像](#全体像) / [構成図](#構成図)  
2. [ブートストラップ手順（人手のみ）](#ブートストラップ手順人手のみ)  
3. [GitHub Environments 設定](#github-environments-設定)  
4. [ローカル実行手順](#ローカル実行手順)  
5. [CI/CD パイプライン詳細](#cicd-パイプライン詳細)  
6. [Policy as Code（OPA/Trivy/Checkov/TFLint/Infracost）](#policy-as-code)  
7. [モジュール群（AWS/Snowflake）](#モジュール群awssnowflake)  
8. [ディレクトリ構成](#ディレクトリ構成)  
9. [セキュリティ対策とベストプラクティス評価](#セキュリティ対策とベストプラクティス評価)  
10. [運用ガイド（ドリフト/プレビュー/監査）](#運用ガイドドリフトプレビュー監査)  
11. [トラブルシュート](#トラブルシュート)

---

## 全体像
- **安全なデフォルト**: `apply` は常に `plan` から、`-lock` により二重実行を防止。  
- **秘密情報**: `*.enc.tfvars` のみリポジトリに保持（SOPS 暗号化）。復号は CI 内・一時ファイルで実施。  
- **OIDC 認証**: GitHub Actions → AWS はロール Assume。Prod は専用ロール + 手動承認 + コストガード。  
- **供給鎖対策**: Provider ミラー / Provenance（attest） / 静的解析 / 直列実行。

### 構成図
```
開発者 → PR → (pr-plan) 静的解析/Plan/Cost → レビュー/承認
                                     ↓
                         (preview) 一時環境（TTL / Close で Destroy）
                                     ↓
              (deploy-nonprod) dev/stg Apply      (deploy-prod) Prod承認→Apply
                                     ↓
                         (drift) 週次ドリフト検知
                                     ↓
                      (attest) Plan Provenance 付与
```

---

## ブートストラップ手順（人手のみ）
> CI からの実行を禁止。多要素・レビューを必須にしてください。

1. **tfstate バックエンド**（S3/DDB/KMS）を作成  
   - S3: バージョニング / Public Access Block / SSE-KMS  
   - DDB: `tf-locks`（`LockID` パーティションキー）
2. **GitHub OIDC ロール**（環境別: Dev/Stg/Prod）  
   - `aud == sts.amazonaws.com`  
   - `sub == repo:<org>/<repo>:ref:refs/heads/main` と `...:pull_request`  
   - `environment in ["Dev","Stg","Prod"]`  
   - Plan/Apply 用に **最小権限ポリシー**を付与（後述）。
3. **Snowflake baseline**（ACCOUNTADMIN のみ）  
   - RBAC ルート / Network Policy（IP 制限）/ Key 運用方針。

---

## GitHub Environments 設定
**Environments**: `Dev`, `Stg`, `Prod`, `Preview` を作成。

- **Variables**  
  - `AWS_REGION=ap-northeast-1`  
  - `AWS_PLAN_ROLE_ARN`（Plan 用 Read ロール）  
  - `AWS_DEV_APPLY_ROLE_ARN`, `AWS_STG_APPLY_ROLE_ARN`, `AWS_PRD_APPLY_ROLE_ARN`  
  - `PREVIEW_TFSTATE_BUCKET=tfstate-yourorg-preview`  
  - `PROD_APPROVERS=login1,login2`
- **Secrets**  
  - `SOPS_AGE_KEY`（Age 秘密鍵）

> **Prod** は必須レビュア / 凍結時間を設定。

---

## ローカル実行手順
```bash
# 1) 依存ツール
brew install terraform sops conftest infracost tflint

# 2) SOPS/AGE キー（初回のみ）
age-keygen -o ./security/keys/agekey.txt
export SOPS_AGE_KEY_FILE=./security/keys/agekey.txt

# 3) dev foundation の初期化/Plan/Apply
make init plan ENV=dev REGION=ap-northeast-1 TARGET=foundation
make apply ENV=dev REGION=ap-northeast-1 TARGET=foundation

# 4) OPA で Plan を評価（任意/推奨）
make opa-test ENV=dev TARGET=foundation
```

---

## CI/CD パイプライン詳細
- **PR Plan**: `pre-commit`（fmt/validate/tflint/trivy/checkov/gitleaks）→ `init/plan` → `show -json` → **OPA/Conftest** → **Infracost** コメント。  
- **NonProd Apply**: OIDC（Dev/Stg ロール）→ SOPS 復号 → `init/plan/apply`。  
- **Prod Apply**: Infracost **ポリシー閾値**で Fail → **手動承認** → `plan/apply`。  
- **Preview**: PR オープンで作成、クローズで Destroy（`preview-janitor.yml` による TTL 清掃付き）。  
- **Drift Detect**: 週次 `-refresh-only -detailed-exitcode`。  
- **Attest**: Plan アーティファクトに Provenance を付与。

> **SHA ピン留め**はセキュリティ上推奨。タグ `@v4` 等は運用開始時に **コミット SHA** へ置換してください。

---

## Policy as Code
- **OPA（`policy/opa/terraform.rego`）**  
  - S3 公開禁止 / SSE 強制 / 必須タグ / 22/tcp の 0.0.0.0/0 禁止。  
  - `conftest test --policy policy/opa stacks/.../plan.json`
- **Trivy / Checkov / TFLint**  
  - IaC の脆弱性・ベストプラクティスを自動検査。結果は PR に表示。  
- **Infracost**  
  - Prod Apply では **10,000 円/月**超の増加で Fail（`policy/infracost.yml`）。

---

## モジュール群（AWS/Snowflake）
- **AWS**: `state-backend`, `vpc-minimal`, `s3-bucket`, `ecr-repo`, `iam-oidc-github`  
- **Snowflake**: `rbac`（YAML → Role/継承）、`warehouse`, `database_schema`, `resource_monitor`, `network_policy`

> RBAC は YAML を `yamldecode()` で読み取り、`snowflake_role` と `snowflake_role_grants` を作成。将来的には **GRANT（DB/Schema/Warehouse, ON FUTURE）**も YAML へ拡張可能です。

---

## ディレクトリ構成
```
.github/workflows/   # PR/Deploy/Preview/Drift/Attest/Janitor（日本語コメント）
bootstrap/           # 初期のみ（CI禁止）
stacks/              # dev/stg/prd/preview（実体環境）
modules/             # 再利用（aws/snowflake）
policy/              # OPA/Trivy/TFLint/Checkov/Infracost
providers/           # 共通 Provider 雛形
bin/                 # ラッパ（tf.sh / sops-decrypt.sh）
security/sops/       # SOPS ルール
controls/            # 監査対応・証跡
```

---

## セキュリティ対策とベストプラクティス評価
### 準拠（◎は強）
- ◎ OIDC 条件の厳格化（repo/workflow/environment）  
- ◎ Secrets の暗号化（SOPS）、復号一時ファイルは削除  
- ◎ 供給鎖対策（Provider ミラー、Provenance、静的解析）  
- ◎ 直列実行（`concurrency`）・state 競合防止  
- ◎ Prod は **コストガード + 手動承認**  
- ○ Preview 環境の自動破棄（TTL Janitor 付き）

### 改善余地
- Actions を **SHA ピン留め**（本番導入時に必須）  
- OPA ポリシーの拡張（RDS/EBS 暗号化、SG 厳格化、IAM Deny * 等）  
- SARIF の **自動アーカイブ**（`controls/evidence/` へ保存）

---

## 運用ガイド（ドリフト/プレビュー/監査）
- **ドリフト**: 週次に検知。exit-code=2 → 差分あり。PR を起票。  
- **プレビュー**: ラベル `ttl/<hours>` で TTL 指定。`preview-janitor.yml` が超過を自動 Destroy。  
- **監査**: `controls/evidence/` にレポートを収集（必要であれば GH Action の upload-artifact を併用）。

---

## トラブルシュート
- `SOPS_AGE_KEY` 未設定 → 復号失敗  
- Plan に OPA/Checkov/Trivy で Fail → PR 上のコメント/ログで該当リソースを特定  
- Drift exit-code=2 → 手動変更か IaC 未反映の可能性

---
