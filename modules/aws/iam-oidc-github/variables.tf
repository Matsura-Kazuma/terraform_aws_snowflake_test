variable "role_name" { type = string }
variable "repo" { type = string }  # org/repo
variable "environments" { type = list(string), default = ["Dev","Stg","Prod"] }
variable "aws_region" { type = string }
variable "policy_json" { type = string } # 最小権限ポリシー（JSON 文字列）
