#------------------------
# Network Security Group
#------------------------
module "network_security_group" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-network-security-group.git?ref=v1.0.0"

  for_each            = var.network_security_group
  name                = each.value.name
  resource_group_name = module.resource_group[each.value.resource_group].name
  location            = var.helpers.region
  inbound_rules       = each.value.inbound_rules
  outbound_rules      = each.value.outbound_rules
  subnet_id           = module.virtual_network[each.value.virtual_network].subnets[each.value.subnet].id

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
output "network_security_group" {
  value = module.network_security_group
}