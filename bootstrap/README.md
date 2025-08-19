# Bootstrap セキュアパック（AWS tfstate / GitHub OIDC / Snowflake Baseline）
最終更新: 2025-08-19

本パックは **本番運用前の初期セットアップ**（人手のみ）に必要な最小構成を一式で提供します。CI からの実行は禁止です。

## ディレクトリ
- aws-state/ — tfstate: S3 + DDB + KMS（local backend で一度だけ）
- github-oidc/ — GitHub Actions → AWS: Plan/Apply ロール（環境別）
- snowflake-baseline/ — Snowflake: ロール/ネットポリシー/リソースモニタ/鍵

## 実行順
1) aws-state -> 2) github-oidc -> 3) snowflake-baseline
