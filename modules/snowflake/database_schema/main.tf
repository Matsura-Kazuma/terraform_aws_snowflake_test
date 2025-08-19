resource "snowflake_database" "db" { name=var.database_name }
resource "snowflake_schema" "schema" { database=snowflake_database.db.name name=var.schema_name is_managed=var.managed_access comment="Managed by Terraform" }
