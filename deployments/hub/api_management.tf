/*
#----------------
# API Management
#----------------
module "api_management" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-api-management.git?ref=v1.0.5"

  for_each            = var.api_management
  name                = "${each.value.name}-${local.resource_suffix}"
  location            = var.helpers.region
  resource_group_name = module.resource_group[each.value.resource_group].name
  publisher_name      = each.value.publisher_name
  publisher_email     = each.value.publisher_email
  sku_name            = each.value.sku_name
  min_api_version     = lookup(each.value, "min_api_version", "2019-12-01")

  identity = {
    type         = each.value.identity.type
    identity_ids = each.value.identity.type == "UserAssigned" || each.value.identity.type == "SystemAssigned, UserAssigned" ? [module.user_assigned_identity[each.value.identity.identity].id] : null
  }

  security                      = lookup(each.value, "security", {})
  public_network_access_enabled = lookup(each.value, "public_network_access_enabled", true)
  environment                   = var.helpers.environment
  api_management_logger_name    = each.value.api_management_logger_name
  resource_id                   = module.application_insights["alpha"].id
  application_insights = {
    instrumentation_key = module.application_insights["alpha"].instrumentation_key
  }
  identifier                = each.value.identifier
  always_log_errors         = lookup(each.value, "always_log_errors", null)
  http_correlation_protocol = lookup(each.value, "http_correlation_protocol", null)
  log_client_ip             = lookup(each.value, "log_client_ip", null)
  sampling_percentage       = lookup(each.value, "sampling_percentage", null)
  verbosity                 = lookup(each.value, "verbosity", null)

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

#---------
# Outputs
#---------
output "api_management" {
  value = module.api_management
}
*/