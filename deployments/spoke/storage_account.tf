#-----------------
# Storage Account
#-----------------
locals {
  storage_account_network_rules = {
    alpha = {
      subnet_details = {
        default = {
          vnet_rg_name = module.virtual_network["alpha"].resource_group_name
          vnet_name    = module.virtual_network["alpha"].name
          subnet_name  = module.virtual_network["alpha"].subnets["default"].name
        },
      }
    },
    beta = {
      subnet_details = {
        default = {
          vnet_rg_name = module.virtual_network["alpha"].resource_group_name
          vnet_name    = module.virtual_network["alpha"].name
          subnet_name  = module.virtual_network["alpha"].subnets["default"].name
        },
      }
    },
  }
}

module "storage_account" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-storage-account.git?ref=v1.0.0"

  for_each                         = var.storage_account
  name                             = lower(replace("${each.value.name}-${local.resource_suffix}", "/[[:^alnum:]]/", ""))
  resource_group_name              = module.resource_group[each.value.resource_group].name
  location                         = var.helpers.region
  account_kind                     = lookup(each.value, "account_kind", "StorageV2")
  account_tier                     = lookup(each.value, "account_tier", "Standard")
  edge_zone                        = lookup(each.value, "edge_zone", null)
  account_replication_type         = lookup(each.value, "account_replication_type", "LRS")
  cross_tenant_replication_enabled = lookup(each.value, "cross_tenant_replication_enabled", true)
  access_tier                      = lookup(each.value, "access_tier", "Hot")
  https_traffic_only_enabled       = lookup(each.value, "https_traffic_only_enabled", true)
  min_tls_version                  = lookup(each.value, "min_tls_version", "TLS1_2")
  allow_nested_items_to_be_public  = lookup(each.value, "allow_nested_items_to_be_public", true)
  shared_access_key_enabled        = lookup(each.value, "shared_access_key_enabled", true)
  public_network_access_enabled    = lookup(each.value, "public_network_access_enabled", true)
  default_to_oauth_authentication  = lookup(each.value, "default_to_oauth_authentication", false)
  is_hns_enabled                   = lookup(each.value, "is_hns_enabled", false)
  nfsv3_enabled                    = lookup(each.value, "nfsv3_enabled", false)
  custom_domain                    = lookup(each.value, "custom_domain", {})
  customer_managed_key             = lookup(each.value, "customer_managed_key", {})
  identity = {
    type         = each.value.identity.type
    identity_ids = each.value.identity.type == "UserAssigned" || each.value.identity.type == "SystemAssigned, UserAssigned" ? [module.user_assigned_identity[each.value.identity.identity].id] : null
  }
  blob_properties                   = lookup(each.value, "blob_properties", {})
  queue_properties                  = lookup(each.value, "queue_properties", {})
  static_website                    = lookup(each.value, "static_website", {})
  share_properties                  = lookup(each.value, "share_properties", {})
  network_rules                     = merge(lookup(each.value, "network_rules", {}), local.storage_account_network_rules[each.key])
  large_file_share_enabled          = lookup(each.value, "large_file_share_enabled", false)
  local_user_enabled                = lookup(each.value, "local_user_enabled", true)
  azure_files_authentication        = lookup(each.value, "azure_files_authentication", {})
  routing                           = lookup(each.value, "routing", {})
  queue_encryption_key_type         = lookup(each.value, "queue_encryption_key_type", "Service")
  table_encryption_key_type         = lookup(each.value, "table_encryption_key_type", null)
  infrastructure_encryption_enabled = lookup(each.value, "infrastructure_encryption_enabled", false)
  immutability_policy               = lookup(each.value, "immutability_policy", {})
  sas_policy                        = lookup(each.value, "sas_policy", {})
  allowed_copy_scope                = lookup(each.value, "allowed_copy_scope", null)
  sftp_enabled                      = lookup(each.value, "sftp_enabled", false)
  dns_endpoint_type                 = lookup(each.value, "dns_endpoint_type", "Standard")

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

#-------------------
# Storage Container
#-------------------
module "storage_container" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-storage-container.git?ref=v1.0.1"

  for_each                          = var.storage_container
  name                              = each.value.name
  storage_account_id                = module.storage_account[each.value.storage_account].id
  container_access_type             = lookup(each.value, "container_access_type", "private")
  default_encryption_scope          = lookup(each.value, "default_encryption_scope", null)
  encryption_scope_override_enabled = lookup(each.value, "encryption_scope_override_enabled", null)
  metadata                          = lookup(each.value, "metadata", {})
}