locals {
  rbac = yamldecode(file(var.role_map_path))
}

resource "snowflake_role" "roles" {
  for_each = { for r in local.rbac.roles : r.name => r }
  name     = each.value.name
  comment  = try(each.value.comment, null)
}

resource "snowflake_role_grants" "role_hierarchy" {
  for_each = {
    for r in local.rbac.roles :
    r.name => r if try(length(r.grant_to_roles) > 0, false)
  }
  role_name = each.key
  roles     = each.value.grant_to_roles
}
