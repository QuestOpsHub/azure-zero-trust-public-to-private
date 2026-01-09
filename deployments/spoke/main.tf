#---------
# Backend 
#---------
terraform {
  backend "azurerm" {}
}

#-------------
# Hub Backend
#-------------
data "terraform_remote_state" "hub" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-qoh-tf-backend-cus"
    storage_account_name = "stqohtfbackendcus7492"
    container_name       = "hub-tfstate"
    key                  = "prod/hub.prod.tfstate"
    subscription_id      = var.hub_subscription_id
    access_key           = data.azurerm_storage_account.storage_account.primary_access_key
  }
}

#---------------
# Random String
#---------------
module "random_string" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-random-string.git?ref=v1.0.0"

  length  = 4
  lower   = true
  numeric = true
  special = false
  upper   = false
}

#----------------
# Resource Group
#----------------
module "resource_group" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-resource-group.git?ref=v1.0.0"

  for_each   = var.resource_group
  name       = "${each.value.name}-${local.resource_suffix}-${module.random_string.result}"
  location   = var.helpers.region
  managed_by = lookup(each.value, "managed_by", null)

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

#-----------------
# Virtual Network
#-----------------
module "virtual_network" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-virtual-network.git?ref=v1.0.0"

  for_each                = var.virtual_network
  name                    = "${each.value.name}-${local.resource_suffix}-${module.random_string.result}"
  resource_group_name     = module.resource_group[each.value.resource_group].name
  location                = var.helpers.region
  address_space           = each.value.address_space
  bgp_community           = lookup(each.value, "bgp_community", null)
  ddos_protection_plan    = lookup(each.value, "ddos_protection_plan", {})
  encryption              = lookup(each.value, "encryption", {})
  dns_servers             = lookup(each.value, "dns_servers", [])
  edge_zone               = lookup(each.value, "edge_zone", null)
  flow_timeout_in_minutes = lookup(each.value, "flow_timeout_in_minutes", null)
  subnet                  = lookup(each.value, "subnet", {})
  subnets                 = lookup(each.value, "subnets", {})

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

#---------------------------------------
# Hub <-> Spoke Virtual Network Peering
#---------------------------------------
module "hub_spoke_peering" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-virtual-network-peering.git?ref=v1.0.0"

  providers = {
    azurerm.hub   = azurerm.hub
    azurerm.spoke = azurerm
  }

  hub_to_spoke                       = "${data.terraform_remote_state.hub.outputs.virtual_network[var.hub_spoke_peering.hub_vnet].name}_to_${module.virtual_network[var.hub_spoke_peering.spoke_vnet].name}"
  hub_rg_name                        = data.terraform_remote_state.hub.outputs.virtual_network[var.hub_spoke_peering.hub_vnet].resource_group_name
  hub_vnet_name                      = data.terraform_remote_state.hub.outputs.virtual_network[var.hub_spoke_peering.hub_vnet].name
  hub_vnet_id                        = data.terraform_remote_state.hub.outputs.virtual_network[var.hub_spoke_peering.hub_vnet].id
  peer1_allow_virtual_network_access = lookup(var.hub_spoke_peering, "peer1_allow_virtual_network_access", true)
  peer1_allow_forwarded_traffic      = lookup(var.hub_spoke_peering, "peer1_allow_forwarded_traffic", false)
  peer1_allow_gateway_transit        = lookup(var.hub_spoke_peering, "peer1_allow_gateway_transit", false)
  peer1_use_remote_gateways          = lookup(var.hub_spoke_peering, "peer1_use_remote_gateways", false)

  spoke_to_hub                       = "${module.virtual_network[var.hub_spoke_peering.spoke_vnet].name}_to_${data.terraform_remote_state.hub.outputs.virtual_network[var.hub_spoke_peering.hub_vnet].name}"
  spoke_rg_name                      = module.virtual_network[var.hub_spoke_peering.spoke_vnet].resource_group_name
  spoke_vnet_name                    = module.virtual_network[var.hub_spoke_peering.spoke_vnet].name
  spoke_vnet_id                      = module.virtual_network[var.hub_spoke_peering.spoke_vnet].id
  peer2_allow_virtual_network_access = lookup(var.hub_spoke_peering, "peer2_allow_virtual_network_access", true)
  peer2_allow_forwarded_traffic      = lookup(var.hub_spoke_peering, "peer2_allow_forwarded_traffic", false)
  peer2_allow_gateway_transit        = lookup(var.hub_spoke_peering, "peer2_allow_gateway_transit", false)
  peer2_use_remote_gateways          = lookup(var.hub_spoke_peering, "peer2_use_remote_gateways", false)
}

#------------------------
# User Assigned Identity
#------------------------
module "user_assigned_identity" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-user-assigned-identity.git?ref=v1.0.0"

  for_each            = var.user_assigned_identity
  name                = "${each.value.name}-${local.resource_suffix}-${module.random_string.result}"
  location            = var.helpers.region
  resource_group_name = module.resource_group[each.value.resource_group].name

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

#-----------------
# Storage Account
#-----------------
locals {
  storage_account_network_rules = {
    func-lin = {
      subnet_details = {
        default = {
          vnet_rg_name = module.virtual_network["default"].resource_group_name
          vnet_name    = module.virtual_network["default"].name
          subnet_name  = module.virtual_network["default"].subnets["default"].name
        },
      }
    },
    func-win = {
      subnet_details = {
        default = {
          vnet_rg_name = module.virtual_network["default"].resource_group_name
          vnet_name    = module.virtual_network["default"].name
          subnet_name  = module.virtual_network["default"].subnets["default"].name
        },
      }
    },
  }
}

module "storage_account" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-storage-account.git?ref=v1.0.0"

  for_each                         = var.storage_account
  name                             = lower(replace("${each.value.name}-${local.resource_suffix}-${module.random_string.result}", "/[[:^alnum:]]/", ""))
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
# module "storage_container" {
#   source = "git::https://github.com/QuestOpsHub/QuestOpsHub-terraform-azure-modules.git//storageContainer?ref=main"

#   for_each             = var.storage_container
#   name                 = each.value.name
#   storage_account_name = module.storage_account[each.value.storage_account].name # @todo remove this property is deprecated in favour of storage_account_id
#   #storage_account_id                = module.storage_account[each.value.storage_account].id
#   container_access_type             = lookup(each.value, "container_access_type", "private")
#   default_encryption_scope          = lookup(each.value, "default_encryption_scope", null)
#   encryption_scope_override_enabled = lookup(each.value, "encryption_scope_override_enabled", null)
#   metadata                          = lookup(each.value, "metadata", {})
# }