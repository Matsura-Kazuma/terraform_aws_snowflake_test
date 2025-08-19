# github-oidc（GitHub Actions → AWS OIDC ロール）
Dev/Stg/Prod 向けの Plan/Apply ロールを作成します。

```bash
cd bootstrap/github-oidc/terraform
terraform init
terraform apply \
  -var='aws_region=ap-northeast-1' \
  -var='repo=your-org/your-repo' \
  -var='environments=["Dev","Stg","Prod"]' \
  -var='requested_region=ap-northeast-1' \
  -var='project_tag_value=SampleProject'
```
出力の Role ARN を GitHub Environments に登録してください。
