terraform { required_providers { snowflake = { source="Snowflake-Labs/snowflake", version="~> 0.99" } } }
variable "allowed_ip_list" { type = list(string) }
resource "snowflake_network_policy" "office_only" { name="NP_OFFICE_ONLY" allowed_ip_list=var.allowed_ip_list }
resource "snowflake_resource_monitor" "monthly" { name="RM_MONTHLY" credit_quota=200 frequency="MONTHLY" start_time="IMMEDIATELY" notify_triggers=[50,80,100] }
