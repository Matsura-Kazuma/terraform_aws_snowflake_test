variable "snowflake_account"         { type = string }
variable "snowflake_user"            { type = string }
variable "snowflake_role"            { type = string }
variable "snowflake_private_key_pem" { type = string }

provider "snowflake" {
  account     = var.snowflake_account
  user        = var.snowflake_user
  role        = var.snowflake_role
  private_key = var.snowflake_private_key_pem
}
