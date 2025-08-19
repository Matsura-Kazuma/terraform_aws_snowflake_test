# aws-state（tfstate 基盤 — 人手のみ）
local backend で S3/DDB/KMS を一度だけ構築します。

```bash
cd bootstrap/aws-state/terraform
terraform init
terraform apply \
  -var='aws_region=ap-northeast-1' \
  -var='tfstate_bucket=tfstate-yourorg-PRD' \
  -var='ddb_table=tf-locks' \
  -var='tags={Project="Platform",Owner="SRE",Environment="bootstrap"}'
```
出力の `backend_hcl` を本体の `stacks/*/backend.hcl` に反映してください。
