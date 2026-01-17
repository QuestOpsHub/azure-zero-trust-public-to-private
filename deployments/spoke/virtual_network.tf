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