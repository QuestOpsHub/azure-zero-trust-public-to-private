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