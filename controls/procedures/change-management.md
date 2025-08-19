# 変更管理（Change Management）
目的: 本番環境へのリスクを最小化し、追跡可能性を確保する。

## 手順（要約）
1. **Issue 作成**（目的/影響範囲/ロールバック手順）
2. **PR 作成** → CI（fmt/validate/tflint/trivy/checkov/gitleaks/plan/infracost）を確認
3. **レビュー/承認**（最低2名、Prod は必須）
4. **一時環境（任意）**で検証（preview + TTL）
5. **Apply**（非本番→本番の順、Prod は手動承認 + コストガード）
6. **検証**（ヘルスチェック/メトリクス/ログ）
7. **証跡保存**（evidence/ に記録: change-ticket, plan.json, 解析結果, apply ログ）
8. **ポストレビュー**（必要なら ADR/SOP 更新）
