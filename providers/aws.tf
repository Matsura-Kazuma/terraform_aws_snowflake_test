variable "aws_region" { type=string }
variable "common_tags" { type=map(string) }
provider "aws" { region=var.aws_region default_tags { tags=var.common_tags } }
