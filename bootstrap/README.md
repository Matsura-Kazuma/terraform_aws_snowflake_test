# Bootstrap（初期のみ・CI禁止）
S3/DDB/KMS, OIDC, Snowflake baseline を人手で構築します。

初回のみの実行は、手動で行う。(プログラムを一回動かすだけ)

# ディレクトリ構造

```
bootstrap/
├─ aws-state/                         # tfstate 用の不変基盤（人手の Terraform 実行）
│  ├─ terraform/
│  │  ├─ main.tf                      # S3/DDB/KMS を local backend で作成
│  │  ├─ variables.tf
│  │  ├─ outputs.tf
│  │  └─ backend.local.example        # ここはあえて local（S3 未作成のため）
│  ├─ policies/
│  │  ├─ s3-bucket-policy.json        # TLS/強制暗号化/パブリック拒否など
│  │  └─ kms-key-policy.json          # 管理・利用権限の分離
│  └─ README.md
│
├─ github-oidc/                       # GitHub Actions → AWS の信頼関係 & 最小権限
│  ├─ terraform/
│  │  ├─ main.tf                      # 環境別ロール（Plan/Apply）を一括作成
│  │  ├─ variables.tf
│  │  └─ outputs.tf
│  ├─ policies/
│  │  ├─ plan-policy.json             # 読み取り専用（Describe/List/Get）
│  │  ├─ apply-boundary.json          # Permission Boundary（上限ガード）
│  │  └─ trust-policy.json            # OIDC 条件（aud/sub/environment）
│  ├─ tests/
│  │  └─ simulate-assume.sh           # 模擬検証（トークンで Assume を試験）
│  └─ README.md
│
└─ snowflake-baseline/                # Snowflake アカウントの最低限整備
   ├─ sql/
   │  ├─ 01_roles.sql                 # 役割階層の作成
   │  ├─ 02_network_policy.sql        # IP 制限
   │  ├─ 03_resource_monitor.sql      # クレジット監視・通知
   │  └─ 04_users_and_keys.sql        # サービスユーザ・公開鍵の登録
   ├─ terraform/
   │  ├─ main.tf                      # （任意）Terraform で baseline の一部を管理
   │  └─ variables.tf
   └─ README.md
```