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