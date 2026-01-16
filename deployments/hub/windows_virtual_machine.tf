#-------------------------
# Windows Virtual Machine
#-------------------------
locals {
  windows_virtual_machine_ip_configuration = {
    alpha = {
      subnet_id = module.virtual_network["alpha"].subnets["default"].id
    },
  }
}

module "windows_virtual_machine" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-windows-virtual-machine.git?ref=v1.0.3"

  for_each                   = var.windows_virtual_machine
  name                       = lower(replace("${each.value.name}-${local.resource_suffix}", "/[[:^alnum:]]/", ""))
  resource_group_name        = module.resource_group[each.value.resource_group].name
  location                   = var.helpers.region
  admin_username             = try(var.admin_username, null)
  admin_password             = try(var.admin_password, null)
  license_type               = lookup(each.value, "license_type", null)
  size                       = each.value.size
  os_disk                    = each.value.os_disk
  allow_extension_operations = lookup(each.value, "allow_extension_operations", true)
  computer_name              = lookup(each.value, "computer_name", null)
  custom_data                = lookup(each.value, "custom_data", null)
  edge_zone                  = lookup(each.value, "edge_zone", null)
  identity = {
    type         = each.value.identity.type
    identity_ids = each.value.identity.type == "UserAssigned" || each.value.identity.type == "SystemAssigned, UserAssigned" ? [module.user_assigned_identity[each.value.identity.identity].id] : null
  }
  provision_vm_agent     = lookup(each.value, "provision_vm_agent", true)
  source_image_id        = lookup(each.value, "source_image_id", null)
  source_image_reference = lookup(each.value, "source_image_reference", null)
  user_data              = lookup(each.value, "user_data", null)
  vtpm_enabled           = lookup(each.value, "vtpm_enabled", null)
  zone                   = lookup(each.value, "zone", null)
  ip_configuration       = merge(lookup(each.value, "ip_configuration", {}), local.windows_virtual_machine_ip_configuration[each.key])
  managed_disks          = each.value.managed_disks

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
    }
  )
}

#---------
# Outputs
#---------
output "windows_virtual_machine" {
  value = module.windows_virtual_machine
}