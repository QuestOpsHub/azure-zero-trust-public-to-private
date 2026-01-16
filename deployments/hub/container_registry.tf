#--------------------
# Container Registry
#--------------------
module "container_registry" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-container-registry.git?ref=v1.0.1"

  for_each                      = var.container_registry
  name                          = replace("${each.value.name}-${local.resource_suffix}", "/[[:^alnum:]]/", "")
  resource_group_name           = module.resource_group[each.value.resource_group].name
  location                      = var.helpers.region
  sku                           = each.value.sku
  admin_enabled                 = lookup(each.value, "admin_enabled", false)
  georeplications               = lookup(each.value, "georeplications", {})
  network_rule_set              = lookup(each.value, "network_rule_set", {})
  public_network_access_enabled = lookup(each.value, "public_network_access_enabled", true)
  quarantine_policy_enabled     = lookup(each.value, "quarantine_policy_enabled", null)
  retention_policy_in_days      = lookup(each.value, "retention_policy_in_days", 7)
  trust_policy_enabled          = lookup(each.value, "trust_policy_enabled", false)
  zone_redundancy_enabled       = lookup(each.value, "zone_redundancy_enabled", false)
  export_policy_enabled         = lookup(each.value, "export_policy_enabled", true)
  encryption                    = lookup(each.value, "encryption", {})
  anonymous_pull_enabled        = lookup(each.value, "anonymous_pull_enabled", null)
  data_endpoint_enabled         = lookup(each.value, "data_endpoint_enabled", null)
  network_rule_bypass_option    = lookup(each.value, "network_rule_bypass_option", "AzureServices")

  identity = {
    type         = each.value.identity.type
    identity_ids = each.value.identity.type == "UserAssigned" || each.value.identity.type == "SystemAssigned, UserAssigned" ? [module.user_assigned_identity[each.value.identity.identity].id] : null
  }

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
output "container_registry" {
  value     = module.container_registry
  sensitive = true
}