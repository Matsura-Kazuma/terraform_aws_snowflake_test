terraform { required_version="~> 1.8" backend "s3" {} }
variable "aws_region" { type=string }
variable "common_tags" { type=map(string) }
module "vpc" { source="../../../../../modules/aws/vpc-minimal" region=var.aws_region tags=var.common_tags }
