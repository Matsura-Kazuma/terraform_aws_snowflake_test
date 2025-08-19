resource "snowflake_resource_monitor" "this" { name=var.name credit_quota=var.credit_quota frequency=var.frequency start_time="IMMEDIATELY" notify_triggers=[50,80,100] }
