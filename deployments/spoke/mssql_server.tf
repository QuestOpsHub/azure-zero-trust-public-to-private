#--------------
# MSSQL Server
#--------------
locals {
  mssql_server = {
    azuread_administrator = {
      alpha = {
        login_username = data.azuread_user.admin_user.user_principal_name
        object_id      = data.azuread_user.admin_user.object_id
      },
    }
  }
}

module "mssql_server" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-mssql-server.git?ref=v1.0.1"

  for_each                     = var.mssql_server
  name                         = "${each.value.name}-${local.resource_suffix}"
  location                     = var.helpers.region
  resource_group_name          = module.resource_group[each.value.resource_group].name
  mssql_server_version         = each.value.mssql_server_version
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
  azuread_administrator        = merge(lookup(each.value, "azuread_administrator", {}), local.mssql_server.azuread_administrator[each.key])
  connection_policy            = lookup(each.value, "connection_policy", "Default")
  identity = {
    type         = each.value.identity.type
    identity_ids = each.value.identity.type == "UserAssigned" || each.value.identity.type == "SystemAssigned, UserAssigned" ? [module.user_assigned_identity[each.value.identity.identity].id] : null
  }
  primary_user_assigned_identity_id = each.value.identity.type == "UserAssigned" || each.value.identity.type == "SystemAssigned, UserAssigned" ? module.user_assigned_identity[each.value.identity.identity].id : null

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

#----------------
# MSSQL Database
#----------------
module "mssql_database" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-mssql-database.git?ref=v1.0.0"

  for_each                    = var.mssql_database
  name                        = "${each.value.name}-${local.resource_suffix}"
  server_id                   = module.mssql_server[each.value.mssql_server].id
  auto_pause_delay_in_minutes = lookup(each.value, "auto_pause_delay_in_minutes", null)
  collation                   = lookup(each.value, "collation", "SQL_Latin1_General_CP1_CI_AS")
  license_type                = lookup(each.value, "license_type", "LicenseIncluded")
  max_size_gb                 = lookup(each.value, "max_size_gb", 250)
  read_scale                  = lookup(each.value, "read_scale", true)
  sku_name                    = lookup(each.value, "sku_name", "P2")
  create_mode                 = lookup(each.value, "create_mode", "Default")

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}