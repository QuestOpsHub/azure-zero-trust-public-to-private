#------------------
# CosmosDB Account
#------------------
module "cosmosdb_account" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-cosmosdb-account.git?ref=v1.0.1"

  for_each                              = var.cosmosdb_account
  name                                  = "${each.value.name}-${local.resource_suffix}"
  location                              = var.helpers.region
  resource_group_name                   = module.resource_group[each.value.resource_group].name
  minimal_tls_version                   = lookup(each.value, "minimal_tls_version", "Tls12")
  offer_type                            = each.value.offer_type
  analytical_storage                    = lookup(each.value, "analytical_storage", {})
  capacity                              = lookup(each.value, "capacity", {})
  create_mode                           = lookup(each.value, "create_mode", null)
  default_identity_type                 = lookup(each.value, "default_identity_type", "FirstPartyIdentity")
  kind                                  = lookup(each.value, "kind", "GlobalDocumentDB")
  consistency_policy                    = each.value.consistency_policy
  geo_location                          = each.value.geo_location
  ip_range_filter                       = lookup(each.value, "ip_range_filter", [])
  free_tier_enabled                     = lookup(each.value, "free_tier_enabled", false)
  analytical_storage_enabled            = lookup(each.value, "analytical_storage_enabled", false)
  automatic_failover_enabled            = lookup(each.value, "automatic_failover_enabled", null)
  partition_merge_enabled               = lookup(each.value, "partition_merge_enabled", false)
  burst_capacity_enabled                = lookup(each.value, "burst_capacity_enabled", false)
  public_network_access_enabled         = lookup(each.value, "public_network_access_enabled", true)
  capabilities                          = lookup(each.value, "capabilities", {})
  is_virtual_network_filter_enabled     = lookup(each.value, "is_virtual_network_filter_enabled", null)
  key_vault_key_id                      = lookup(each.value, "key_vault_key_id", null)
  managed_hsm_key_id                    = lookup(each.value, "managed_hsm_key_id", null)
  virtual_network_rule                  = lookup(each.value, "virtual_network_rule", {})
  multiple_write_locations_enabled      = lookup(each.value, "multiple_write_locations_enabled", null)
  access_key_metadata_writes_enabled    = lookup(each.value, "access_key_metadata_writes_enabled", true)
  mongo_server_version                  = lookup(each.value, "mongo_server_version", null)
  network_acl_bypass_for_azure_services = lookup(each.value, "network_acl_bypass_for_azure_services", false)
  network_acl_bypass_ids                = lookup(each.value, "network_acl_bypass_ids", [])
  local_authentication_disabled         = lookup(each.value, "local_authentication_disabled", false)
  backup                                = lookup(each.value, "backup", {})
  cors_rule                             = lookup(each.value, "cors_rule", {})
  identity = {
    type         = each.value.identity.type
    identity_ids = each.value.identity.type == "UserAssigned" || each.value.identity.type == "SystemAssigned, UserAssigned" ? [module.user_assigned_identity[each.value.identity.identity].id] : null
  }
  restore = lookup(each.value, "restore", {})

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}