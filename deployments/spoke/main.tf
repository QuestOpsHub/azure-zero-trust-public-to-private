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
    storage_account_name = "stqohtfbackendcus9284"
    container_name       = "hub-tfstate"
    key                  = "prod/hub.prod.tfstate"
    subscription_id      = var.hub_subscription_id
    access_key           = data.azurerm_storage_account.storage_account.primary_access_key
  }
}

#----------------
# Resource Group
#----------------
module "resource_group" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-resource-group.git?ref=v1.0.0"

  for_each   = var.resource_group
  name       = "${each.value.name}-${local.resource_suffix}"
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
  name                    = "${each.value.name}-${local.resource_suffix}"
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
  name                = "${each.value.name}-${local.resource_suffix}"
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

#-----------
# Key Vault
#-----------
locals {
  key_vault_access_policy = {
    alpha = {
      admin_user = {
        object_id               = data.azuread_user.admin_user.object_id
        key_permissions         = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
        secret_permissions      = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
        certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
        storage_permissions     = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"]
      },
      spoke_service_principal = {
        object_id               = data.azuread_service_principal.spoke_service_principal.object_id
        key_permissions         = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
        secret_permissions      = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
        certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
        storage_permissions     = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"]
      },
    },
  }
  key_vault_network_acls = {
    alpha = {
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

module "key_vault" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-key-vault.git?ref=v1.0.0"

  for_each                        = var.key_vault
  name                            = "${each.value.name}-${local.resource_suffix}"
  location                        = var.helpers.region
  resource_group_name             = module.resource_group[each.value.resource_group].name
  sku_name                        = each.value.sku_name
  access_policy                   = merge(lookup(each.value, "access_policy", {}), local.key_vault_access_policy[each.key])
  enabled_for_deployment          = lookup(each.value, "enabled_for_deployment", null)
  enabled_for_disk_encryption     = lookup(each.value, "enabled_for_disk_encryption", null)
  enabled_for_template_deployment = lookup(each.value, "enabled_for_template_deployment", null)
  enable_rbac_authorization       = lookup(each.value, "enable_rbac_authorization", null)
  network_acls                    = merge(lookup(each.value, "network_acls", {}), local.key_vault_network_acls[each.key])
  purge_protection_enabled        = lookup(each.value, "purge_protection_enabled", null)
  public_network_access_enabled   = lookup(each.value, "public_network_access_enabled", true)
  soft_delete_retention_days      = lookup(each.value, "soft_delete_retention_days", null)

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      owner = lookup(var.key_vault, "resource_tags", local.resource_tags).owner
      team  = lookup(var.key_vault, "resource_tags", local.resource_tags).team
    }
  )
}

#------------------
# Key Vault Secret
#------------------
module "key_vault_secret" {
  depends_on = [module.key_vault]
  source     = "git::https://github.com/QuestOpsHub/terraform-azurerm-key-vault-secret.git?ref=v1.0.0"

  for_each        = var.key_vault_secret
  name            = each.value.name
  value           = each.value.value
  key_vault_id    = module.key_vault[each.value.key_vault].id
  content_type    = lookup(each.value, "content_type", null)
  not_before_date = lookup(each.value, "not_before_date", null)
  expiration_date = lookup(each.value, "expiration_date", null)

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

#--------------
# Service Plan
#--------------
module "service_plan" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-service-plan.git?ref=v1.0.0"

  for_each                     = var.service_plan
  name                         = "${each.value.name}-${local.resource_suffix}"
  location                     = var.helpers.region
  resource_group_name          = module.resource_group[each.value.resource_group].name
  os_type                      = each.value.os_type
  sku_name                     = each.value.sku_name
  app_service_environment_id   = lookup(each.value, "app_service_environment_id", null)
  maximum_elastic_worker_count = lookup(each.value, "maximum_elastic_worker_count", null)
  worker_count                 = lookup(each.value, "worker_count", 1)
  per_site_scaling_enabled     = lookup(each.value, "per_site_scaling_enabled", false)
  zone_balancing_enabled       = lookup(each.value, "zone_balancing_enabled", false)

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

#----------------------
# Application Insights
#----------------------
module "application_insights" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-application-insights.git?ref=v1.0.1"

  for_each                              = var.application_insights
  name                                  = "${each.value.name}-${local.resource_suffix}"
  location                              = var.helpers.region
  resource_group_name                   = module.resource_group[each.value.resource_group].name
  application_type                      = each.value.application_type
  daily_data_cap_in_gb                  = lookup(each.value, "daily_data_cap_in_gb", 100)
  daily_data_cap_notifications_disabled = lookup(each.value, "daily_data_cap_notifications_disabled", false)
  retention_in_days                     = lookup(each.value, "retention_in_days", 90)
  sampling_percentage                   = lookup(each.value, "sampling_percentage", 100)
  disable_ip_masking                    = lookup(each.value, "disable_ip_masking", false)
  workspace_id                          = lookup(each.value, "workspace_id", null)
  local_authentication_disabled         = lookup(each.value, "local_authentication_disabled", false)
  internet_ingestion_enabled            = lookup(each.value, "internet_ingestion_enabled", true)
  internet_query_enabled                = lookup(each.value, "internet_query_enabled", true)
  force_customer_storage_for_profiler   = lookup(each.value, "force_customer_storage_for_profiler", false)

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

#---------------
# Linux Web App
#---------------
locals {
  app_linux_site_config = {
    alpha = {
      container_registry_managed_identity_client_id = module.user_assigned_identity["app-lin"].client_id
    },
  }
  app_linux_app_settings = {
    alpha = {
      APPINSIGHTS_INSTRUMENTATIONKEY             = module.application_insights["appi-app-lin"].instrumentation_key
      APPLICATIONINSIGHTS_CONNECTION_STRING      = module.application_insights["appi-app-lin"].connection_string
      APPINSIGHTS_PROFILERFEATURE_VERSION        = "1.0.0"
      APPINSIGHTS_SNAPSHOTFEATURE_VERSION        = "1.0.0"
      ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
      DiagnosticServices_EXTENSION_VERSION       = "~3"
      PORT                                       = "3000"
      WEBSITES_ENABLE_APP_SERVICE_STORAGE        = false
      WEBSITES_PORT                              = "3000"
    },
  }
  app_linux_auth_settings = {
    alpha = {},
  }
  app_linux_auth_settings_v2 = {
    alpha = {},
  }
  app_linux_backup = {
    alpha = {},
  }
  app_linux_connection_string = {
    alpha = {},
  }
  app_linux_logs = {
    alpha = {},
  }
  app_linux_storage_account = {
    alpha = {},
  }
  app_linux_sticky_settings = {
    alpha = {
      app_setting_names = ["APPLICATION_SLOT_NAME"]
    },
  }
  app_linux_slot_app_settings = {
    alpha = {
      APPLICATION_SLOT_NAME = "staging"
    },
  }
}

module "linux_web_app" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-linux-webapp.git?ref=v1.0.0"

  for_each                                 = var.linux_web_app
  name                                     = "${each.value.name}-${local.resource_suffix}"
  location                                 = var.helpers.region
  resource_group_name                      = module.resource_group[each.value.resource_group].name
  service_plan_id                          = module.service_plan[each.value.service_plan].id
  site_config                              = merge(lookup(each.value, "site_config", {}), local.app_linux_site_config[each.key])
  app_settings                             = merge(lookup(each.value, "app_settings", {}), local.app_linux_app_settings[each.key])
  auth_settings                            = merge(lookup(each.value, "auth_settings", {}), local.app_linux_auth_settings[each.key])
  auth_settings_v2                         = merge(lookup(each.value, "auth_settings_v2", {}), local.app_linux_auth_settings_v2[each.key])
  backup                                   = merge(lookup(each.value, "backup", {}), local.app_linux_backup[each.key])
  client_affinity_enabled                  = lookup(each.value, "client_affinity_enabled", null)
  client_certificate_enabled               = lookup(each.value, "client_certificate_enabled", null)
  client_certificate_mode                  = lookup(each.value, "client_certificate_mode", "Required")
  client_certificate_exclusion_paths       = lookup(each.value, "client_certificate_exclusion_paths", null)
  connection_string                        = merge(lookup(each.value, "connection_string", {}), local.app_linux_connection_string[each.key])
  enabled                                  = lookup(each.value, "enabled", true)
  ftp_publish_basic_authentication_enabled = lookup(each.value, "ftp_publish_basic_authentication_enabled", true)
  https_only                               = lookup(each.value, "https_only", false)
  public_network_access_enabled            = lookup(each.value, "public_network_access_enabled", true)
  identity = {
    type         = each.value.identity.type
    identity_ids = each.value.identity.type == "UserAssigned" || each.value.identity.type == "SystemAssigned, UserAssigned" ? [module.user_assigned_identity[each.value.identity.identity].id] : null
  }
  key_vault_reference_identity_id                = lookup(each.value, "key_vault_reference_identity_id", null)
  logs                                           = merge(lookup(each.value, "logs", {}), local.app_linux_logs[each.key])
  storage_account                                = merge(lookup(each.value, "storage_account", {}), local.app_linux_storage_account[each.key])
  sticky_settings                                = merge(lookup(each.value, "sticky_settings", {}), local.app_linux_sticky_settings[each.key])
  virtual_network_subnet_id                      = lookup(each.value, "virtual_network_subnet_id", null)
  webdeploy_publish_basic_authentication_enabled = lookup(each.value, "webdeploy_publish_basic_authentication_enabled", true)
  zip_deploy_file                                = lookup(each.value, "zip_deploy_file", null)
  enable_staging_slot                            = lookup(each.value, "enable_staging_slot", false)
  slot_app_settings                              = merge(lookup(each.value, "slot_app_settings", {}), local.app_linux_slot_app_settings[each.key])
  slot_https_only                                = lookup(each.value, "slot_https_only", false)
  staging_slot_service_plan_id                   = lookup(each.value, "staging_slot_service_plan_id", null)
  enable_management_lock                         = lookup(each.value, "enable_management_lock", false)

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

#--------------------
# Linux Function App
#--------------------
locals {
  func_linux_site_config = {
    alpha = {
      application_insights_key               = module.application_insights["appi-func-lin"].instrumentation_key
      application_insights_connection_string = module.application_insights["appi-func-lin"].connection_string
    },
    beta = {
      application_insights_key               = module.application_insights["appi-func-lin"].instrumentation_key
      application_insights_connection_string = module.application_insights["appi-func-lin"].connection_string
    },
  }
  func_linux_app_settings = {
    alpha = {
      AZURE_TENANT_ID                     = var.tenant_id
      AZURE_CLIENT_ID                     = var.client_id
      AZURE_CLIENT_SECRET                 = var.client_secret
      AZURE_KV_URL                        = module.key_vault["alpha"].vault_uri
      FUNCTIONS_EXTENSION_VERSION         = "~4"
      FUNCTIONS_WORKER_RUNTIME            = "node"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE     = true
      WEBSITES_ENABLE_APP_SERVICE_STORAGE = true
      REV_REC_SCHEDULE                    = "0 0 9 * * *"
    },
    beta = {
      AZURE_TENANT_ID                     = var.tenant_id
      AZURE_CLIENT_ID                     = var.client_id
      AZURE_CLIENT_SECRET                 = var.client_secret
      AZURE_KV_URL                        = module.key_vault["alpha"].vault_uri
      FUNCTIONS_EXTENSION_VERSION         = "~4"
      FUNCTIONS_WORKER_RUNTIME            = "java"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE     = true
      WEBSITES_ENABLE_APP_SERVICE_STORAGE = true
      REV_REC_SCHEDULE                    = "0 0 9 * * *"
    },
  }
  func_linux_auth_settings = {
    alpha = {},
    beta  = {},
  }
  func_linux_auth_settings_v2 = {
    alpha = {},
    beta  = {},
  }
  func_linux_backup = {
    alpha = {},
    beta  = {},
  }
  func_linux_storage_account = {
    alpha = {},
    beta  = {},
  }
}

module "linux_function_app" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-linux-function-app.git?ref=v1.0.0"

  for_each                                 = var.linux_function_app
  name                                     = "${each.value.name}-${local.resource_suffix}"
  location                                 = var.helpers.region
  resource_group_name                      = module.resource_group[each.value.resource_group].name
  service_plan_id                          = module.service_plan[each.value.service_plan].id
  site_config                              = merge(lookup(each.value, "site_config", {}), local.func_linux_site_config[each.key])
  app_settings                             = merge(lookup(each.value, "app_settings", {}), local.func_linux_app_settings[each.key])
  auth_settings                            = merge(lookup(each.value, "auth_settings", {}), local.func_linux_auth_settings[each.key])
  auth_settings_v2                         = merge(lookup(each.value, "auth_settings_v2", {}), local.func_linux_auth_settings_v2[each.key])
  backup                                   = merge(lookup(each.value, "backup", {}), local.func_linux_backup[each.key])
  builtin_logging_enabled                  = lookup(each.value, "builtin_logging_enabled", true)
  client_certificate_enabled               = lookup(each.value, "client_certificate_enabled", null)
  client_certificate_mode                  = lookup(each.value, "client_certificate_mode", "Optional")
  client_certificate_exclusion_paths       = lookup(each.value, "client_certificate_exclusion_paths", null)
  connection_string                        = lookup(each.value, "connection_string", {})
  daily_memory_time_quota                  = lookup(each.value, "daily_memory_time_quota", "0")
  enabled                                  = lookup(each.value, "enabled", true)
  content_share_force_disabled             = lookup(each.value, "content_share_force_disabled", null)
  functions_extension_version              = lookup(each.value, "functions_extension_version", "~4")
  ftp_publish_basic_authentication_enabled = lookup(each.value, "ftp_publish_basic_authentication_enabled", true)
  https_only                               = lookup(each.value, "https_only", true)
  public_network_access_enabled            = lookup(each.value, "public_network_access_enabled", true)
  identity = {
    type         = each.value.identity.type
    identity_ids = each.value.identity.type == "UserAssigned" || each.value.identity.type == "SystemAssigned, UserAssigned" ? [module.user_assigned_identity[each.value.identity.identity].id] : null
  }
  key_vault_reference_identity_id                = module.user_assigned_identity[each.value.identity.identity].id
  storage_account                                = merge(lookup(each.value, "storage_account_block", {}), local.func_linux_storage_account[each.key])
  sticky_settings                                = lookup(each.value, "sticky_settings", {})
  storage_account_access_key                     = module.storage_account[each.value.storage_account].primary_access_key
  storage_account_name                           = module.storage_account[each.value.storage_account].name
  storage_uses_managed_identity                  = lookup(each.value, "storage_uses_managed_identity", null) # @todo why?
  storage_key_vault_secret_id                    = lookup(each.value, "storage_key_vault_secret_id", null)
  virtual_network_subnet_id                      = lookup(each.value, "virtual_network_subnet_id", null)
  webdeploy_publish_basic_authentication_enabled = lookup(each.value, "webdeploy_publish_basic_authentication_enabled", true)
  zip_deploy_file                                = lookup(each.value, "zip_deploy_file", null)

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

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

#-------------------
# Private End Point
#-------------------
locals {
  private_dns_zone_group = {
    cosmon-alpha = {
      name                 = data.terraform_remote_state.hub.outputs.private_dns_zone["Sql"].name
      private_dns_zone_ids = [data.terraform_remote_state.hub.outputs.private_dns_zone["Sql"].id]
    }
    kv-alpha = {
      name                 = data.terraform_remote_state.hub.outputs.private_dns_zone["vault"].name
      private_dns_zone_ids = [data.terraform_remote_state.hub.outputs.private_dns_zone["vault"].id]
    }
    st-alpha = {
      name                 = data.terraform_remote_state.hub.outputs.private_dns_zone["blob"].name
      private_dns_zone_ids = [data.terraform_remote_state.hub.outputs.private_dns_zone["blob"].id]
    }
    st-beta = {
      name                 = data.terraform_remote_state.hub.outputs.private_dns_zone["blob"].name
      private_dns_zone_ids = [data.terraform_remote_state.hub.outputs.private_dns_zone["blob"].id]
    }
    app-alpha = {
      name                 = data.terraform_remote_state.hub.outputs.private_dns_zone["sites"].name
      private_dns_zone_ids = [data.terraform_remote_state.hub.outputs.private_dns_zone["sites"].id]
    }
    func-alpha = {
      name                 = data.terraform_remote_state.hub.outputs.private_dns_zone["sites"].name
      private_dns_zone_ids = [data.terraform_remote_state.hub.outputs.private_dns_zone["sites"].id]
    }
    func-beta = {
      name                 = data.terraform_remote_state.hub.outputs.private_dns_zone["sites"].name
      private_dns_zone_ids = [data.terraform_remote_state.hub.outputs.private_dns_zone["sites"].id]
    }
  }

  private_service_connection = {
    cosmon-alpha = {
      name                           = "${module.cosmosdb_account["alpha"].name}-privateserviceconnection"
      private_connection_resource_id = module.cosmosdb_account["alpha"].id
    }
    kv-alpha = {
      name                           = "${module.key_vault["alpha"].name}-privateserviceconnection"
      private_connection_resource_id = module.key_vault["alpha"].id
    }
    st-alpha = {
      name                           = "${module.storage_account["alpha"].name}-privateserviceconnection"
      private_connection_resource_id = module.storage_account["alpha"].id
    }
    st-beta = {
      name                           = "${module.storage_account["beta"].name}-privateserviceconnection"
      private_connection_resource_id = module.storage_account["beta"].id
    }
    app-alpha = {
      name                           = "${module.linux_web_app["alpha"].name}-privateserviceconnection"
      private_connection_resource_id = module.linux_web_app["alpha"].id
    }
    func-alpha = {
      name                           = "${module.linux_function_app["alpha"].name}-privateserviceconnection"
      private_connection_resource_id = module.linux_function_app["alpha"].id
    }
    func-beta = {
      name                           = "${module.linux_function_app["beta"].name}-privateserviceconnection"
      private_connection_resource_id = module.linux_function_app["beta"].id
    }
  }
}

module "private_endpoint" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-private-endpoint.git?ref=v1.0.0"

  for_each                      = var.private_endpoint
  name                          = "${each.value.name}-${local.resource_suffix}"
  resource_group_name           = module.resource_group[each.value.resource_group].name
  location                      = var.helpers.region
  subnet_id                     = module.virtual_network["alpha"].subnets["default"].id
  custom_network_interface_name = lookup(each.value, "custom_network_interface_name", null)
  private_dns_zone_group        = merge(lookup(each.value, "private_dns_zone_group", {}), local.private_dns_zone_group[each.key])
  private_service_connection    = merge(lookup(each.value, "private_service_connection", {}), local.private_service_connection[each.key])
  ip_configuration              = lookup(each.value, "ip_configuration", {})

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

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
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-mssql-server.git?ref=v1.0.0"

  for_each                     = var.mssql_server
  name                         = "${each.value.name}-${local.resource_suffix}"
  location                     = var.helpers.region
  resource_group_name          = module.resource_group[each.value.resource_group].name
  version                      = each.value.version
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
  azuread_administrator        = merge(lookup(each.value, "azuread_administrator", {}), local.mssql_server.azuread_administrator[each.key])
  connection_policy            = lookup(each.value, "connection_policy", "Default")
  identity = {
    type         = each.value.identity.type
    identity_ids = each.value.identity.type == "UserAssigned" || each.value.identity.type == "SystemAssigned, UserAssigned" ? [module.user_assigned_identity[each.value.identity.identity].id] : null
  }
  primary_user_assigned_identity_id = each.value.identity.type == "UserAssigned" || each.value.identity.type == "SystemAssigned, UserAssigned" ? module.user_identity[each.value.identity.identity].id : null

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
  mssql_database_name         = "${each.value.name}-${local.resource_suffix}"
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