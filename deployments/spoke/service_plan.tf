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