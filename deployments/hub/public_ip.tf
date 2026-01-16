#-----------
# Public IP
#-----------
module "public_ip" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-public-ip.git?ref=v1.0.0"

  for_each                = var.public_ip
  name                    = "${each.value.name}-${local.resource_suffix}"
  location                = var.helpers.region
  resource_group_name     = module.resource_group[each.value.resource_group].name
  allocation_method       = each.value.allocation_method
  zones                   = lookup(each.value, "zones", [1])
  ddos_protection_mode    = lookup(each.value, "ddos_protection_mode", "VirtualNetworkInherited")
  ddos_protection_plan_id = lookup(each.value, "ddos_protection_plan_id", null)
  domain_name_label       = lookup(each.value, "domain_name_label", null)
  edge_zone               = lookup(each.value, "edge_zone", null)
  idle_timeout_in_minutes = lookup(each.value, "idle_timeout_in_minutes", 4)
  ip_tags                 = lookup(each.value, "ip_tags", {})
  public_ip_prefix_id     = lookup(each.value, "public_ip_prefix_id", null)
  reverse_fqdn            = lookup(each.value, "reverse_fqdn", null)
  sku                     = lookup(each.value, "sku", "Standard")
  sku_tier                = lookup(each.value, "sku_tier", "Regional")

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
output "public_ip" {
  value = module.public_ip
}