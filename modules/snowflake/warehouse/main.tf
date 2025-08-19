resource "snowflake_warehouse" "this" { name=var.name warehouse_size=var.size auto_suspend=var.auto_suspend auto_resume=true statement_timeout_in_seconds=600 }
output "warehouse_name" { value=snowflake_warehouse.this.name }
