variable "role_name" { type=string }
variable "repo" { type=string }
variable "environments" { type=list(string), default=["Dev","Stg","Prod"] }
variable "aws_region" { type=string }
variable "policy_json" { type=string }
