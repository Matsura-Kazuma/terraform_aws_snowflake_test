data "aws_iam_openid_connect_provider" "github" { url="https://token.actions.githubusercontent.com" }
resource "aws_iam_role" "github_oidc" {
  name=var.role_name
  assume_role_policy=jsonencode({
    Version="2012-10-17",
    Statement=[{Effect="Allow",Principal={Federated=data.aws_iam_openid_connect_provider.github.arn},Action="sts:AssumeRoleWithWebIdentity",Condition={"StringEquals"={"token.actions.githubusercontent.com:aud"="sts.amazonaws.com"},"StringLike"={"token.actions.githubusercontent.com:sub"=["repo:${var.repo}:ref:refs/heads/main","repo:${var.repo}:pull_request"],"token.actions.githubusercontent.com:environment"=var.environments}}}]
  })
  inline_policy { name="least-priv" policy=var.policy_json }
}
output "role_arn" { value=aws_iam_role.github_oidc.arn }
