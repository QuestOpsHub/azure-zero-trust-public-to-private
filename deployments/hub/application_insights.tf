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