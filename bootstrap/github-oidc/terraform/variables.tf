variable "aws_region" { type=string }
variable "repo" { type=string }              # your-org/your-repo
variable "environments" { type=list(string) }
variable "requested_region" { type=string }
variable "project_tag_value" { type=string }
