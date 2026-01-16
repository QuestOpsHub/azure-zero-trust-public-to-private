#--------------
# Bastion Host
#--------------
locals {
  bastion_host_ip_configuration = {
    alpha = {
      subnet_id            = module.virtual_network["alpha"].subnets["bastion"].id
      public_ip_address_id = module.public_ip["alpha"].id
    }
  }
}

module "bastion_host" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-bastion-host.git?ref=v1.0.0"

  for_each                  = var.bastion_host
  name                      = "${each.value.name}-${local.resource_suffix}"
  location                  = var.helpers.region
  resource_group_name       = module.resource_group[each.value.resource_group].name
  copy_paste_enabled        = lookup(each.value, "copy_paste_enabled", true)
  file_copy_enabled         = lookup(each.value, "file_copy_enabled", false)
  sku                       = lookup(each.value, "sku", "Basic")
  ip_configuration          = merge(lookup(each.value, "ip_configuration", {}), local.bastion_host_ip_configuration[each.key])
  ip_connect_enabled        = lookup(each.value, "ip_connect_enabled", false)
  kerberos_enabled          = lookup(each.value, "kerberos_enabled", false)
  scale_units               = lookup(each.value, "scale_units", 2)
  shareable_link_enabled    = lookup(each.value, "shareable_link_enabled", false)
  tunneling_enabled         = lookup(each.value, "tunneling_enabled", false)
  session_recording_enabled = lookup(each.value, "session_recording_enabled", false)
  virtual_network_id        = lookup(each.value, "virtual_network_id", null)
  zones                     = lookup(each.value, "zones", [])

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
output "bastion_host" {
  value = module.bastion_host
}