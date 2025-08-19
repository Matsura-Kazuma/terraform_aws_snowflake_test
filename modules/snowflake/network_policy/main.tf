resource "snowflake_network_policy" "np" { name=var.name allowed_ip_list=var.allowed_ip_list }
