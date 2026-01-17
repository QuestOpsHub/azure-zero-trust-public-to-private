#------------------------
# MSSQL Managed Instance
#------------------------
module "mssql_managed_instance" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-mssql-managed-instance.git?ref=v1.0.0"

  for_each                     = var.mssql_managed_instance
  name                         = "${each.value.name}-${local.resource_suffix}"
  resource_group_name          = module.resource_group[each.value.resource_group].name
  location                     = var.helpers.region
  license_type                 = each.value.license_type
  sku_name                     = each.value.sku_name
  storage_size_in_gb           = each.value.storage_size_in_gb
  subnet_id                    = module.virtual_network["alpha"].subnets["default"].id
  vcores                       = each.value.vcores
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
  collation                    = lookup(each.value, "collation", null)
  dns_zone_partner_id          = lookup(each.value, "dns_zone_partner_id", null)
  identity = {
    type         = each.value.identity.type
    identity_ids = each.value.identity.type == "UserAssigned" || each.value.identity.type == "SystemAssigned, UserAssigned" ? [module.user_assigned_identity[each.value.identity.identity].id] : null
  }
  maintenance_configuration_name = lookup(each.value, "maintenance_configuration_name", "SQL_Default")
  minimum_tls_version            = lookup(each.value, "minimum_tls_version", "1.2")
  proxy_override                 = lookup(each.value, "proxy_override", "Default")
  public_data_endpoint_enabled   = lookup(each.value, "public_data_endpoint_enabled", false)
  storage_account_type           = lookup(each.value, "storage_account_type", "GRS")
  timezone_id                    = lookup(each.value, "timezone_id", "UTC")
  enable_security_alert_policy   = lookup(each.value, "enable_security_alert_policy", false)
  disabled_alerts                = lookup(each.value, "disabled_alerts", [])
  enabled                        = lookup(each.value, "enabled", false)
  email_account_admins_enabled   = lookup(each.value, "email_account_admins_enabled", false)
  email_addresses                = lookup(each.value, "email_addresses", [])
  retention_days                 = lookup(each.value, "retention_days", "0")
  storage_endpoint               = lookup(each.value, "storage_endpoint", null)
  storage_account_access_key     = lookup(each.value, "storage_account_access_key", null)

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

#------------------------
# MSSQL Managed Database
#------------------------
module "mssql_managed_database" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-mssql-managed-database.git?ref=v1.0.0"

  for_each                   = var.mssql_managed_database
  name                       = "${each.value.name}-${local.resource_suffix}"
  managed_instance_id        = module.mssql_managed_instance[each.value.mssql_managed_instance].id
  long_term_retention_policy = lookup(each.value, "long_term_retention_policy", null)
  short_term_retention_days  = lookup(each.value, "short_term_retention_days", null)
}