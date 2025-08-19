terraform { required_version = "~> 1.8" }
provider "aws" { region = var.aws_region }
resource "aws_kms_key" "tfstate" { description="Terraform state" enable_key_rotation=true tags=var.tags }
resource "aws_kms_alias" "tfstate" { name="alias/tfstate-bootstrap" target_key_id=aws_kms_key.tfstate.key_id }
resource "aws_s3_bucket" "tfstate" { bucket=var.tfstate_bucket tags=var.tags }
resource "aws_s3_bucket_versioning" "tfstate" { bucket=aws_s3_bucket.tfstate.id versioning_configuration { status="Enabled" } }
resource "aws_s3_bucket_public_access_block" "tfstate" { bucket=aws_s3_bucket.tfstate.id block_public_acls=true block_public_policy=true ignore_public_acls=true restrict_public_buckets=true }
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" { bucket=aws_s3_bucket.tfstate.id rule { apply_server_side_encryption_by_default { sse_algorithm="aws:kms" kms_master_key_id=aws_kms_key.tfstate.arn } } }
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
resource "aws_s3_bucket_policy" "tfstate" { bucket=aws_s3_bucket.tfstate.id policy=templatefile("${path.module}/../policies/s3-bucket-policy.tpl",{bucket_name=var.tfstate_bucket,partition=data.aws_partition.current.partition,account_id=data.aws_caller_identity.current.account_id}) }
resource "aws_dynamodb_table" "locks" { name=var.ddb_table billing_mode="PAY_PER_REQUEST" hash_key="LockID" attribute { name="LockID" type="S" } tags=var.tags }
output "kms_key_arn" { value = aws_kms_key.tfstate.arn }
output "tfstate_bucket" { value = aws_s3_bucket.tfstate.bucket }
output "ddb_locks_table" { value = aws_dynamodb_table.locks.name }
output "backend_hcl" { value = <<EOT
bucket         = "${aws_s3_bucket.tfstate.bucket}"
key            = "DEV/ap-northeast-1/foundation/terraform.tfstate"
region         = "${var.aws_region}"
dynamodb_table = "${aws_dynamodb_table.locks.name}"
encrypt        = true
kms_key_id     = "${aws_kms_key.tfstate.arn}"
EOT
}
