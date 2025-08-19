terraform { required_version="~> 1.8" }
provider "aws" { region = var.aws_region }
data "aws_caller_identity" "current" {}
data "aws_iam_openid_connect_provider" "github" { url="https://token.actions.githubusercontent.com" }
locals {
  envs = toset(var.environments)
  trust_policy_js = templatefile("${path.module}/../policies/trust-policy.tpl",{
    account_id = data.aws_caller_identity.current.account_id,
    repo = var.repo,
    environments_json = jsonencode(var.environments)
  })
  plan_policy_js = templatefile("${path.module}/../policies/plan-policy.tpl",{
    requested_region = var.requested_region
  })
  boundary_js = templatefile("${path.module}/../policies/apply-boundary.tpl",{
    requested_region = var.requested_region,
    project_tag_value = var.project_tag_value
  })
}
resource "aws_iam_policy" "plan" { name="gha-plan-readonly" policy=local.plan_policy_js }
resource "aws_iam_policy" "apply_boundary" { name="gha-apply-boundary" policy=local.boundary_js }
resource "aws_iam_role" "plan" {
  for_each = local.envs
  name = "gha-plan-${each.key}"
  assume_role_policy = local.trust_policy_js
  managed_policy_arns = [aws_iam_policy.plan.arn]
  tags = { Environment = each.key }
}
resource "aws_iam_role" "apply" {
  for_each = local.envs
  name = "gha-apply-${each.key}"
  assume_role_policy = local.trust_policy_js
  permissions_boundary = aws_iam_policy.apply_boundary.arn
  tags = { Environment = each.key }
}
output "plan_role_arns"  { value = { for k, v in aws_iam_role.plan  : k => v.arn } }
output "apply_role_arns" { value = { for k, v in aws_iam_role.apply : k => v.arn } }
