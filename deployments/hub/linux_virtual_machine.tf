#-----------------------
# Linux Virtual Machine
#-----------------------
locals {
  linux_virtual_machine_ip_configuration = {
    alpha = {
      subnet_id = module.virtual_network["alpha"].subnets["default"].id
    },
  }
  custom_data = {
    alpha = {
      custom_data = filebase64("${path.module}/scripts/mountDisks.sh")
    }
  }
}

module "linux_virtual_machine" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-linux-virtual-machine.git?ref=v1.0.1"

  for_each                                               = var.linux_virtual_machine
  name                                                   = "${each.value.name}-${local.resource_suffix}"
  resource_group_name                                    = module.resource_group[each.value.resource_group].name
  location                                               = var.helpers.region
  admin_username                                         = var.admin_username
  admin_password                                         = var.admin_password
  license_type                                           = lookup(each.value, "license_type", null)
  size                                                   = each.value.size
  os_disk                                                = each.value.os_disk
  additional_capabilities                                = lookup(each.value, "additional_capabilities", {})
  admin_ssh_key                                          = lookup(each.value, "admin_ssh_key", {})
  allow_extension_operations                             = lookup(each.value, "allow_extension_operations", true)
  availability_set_id                                    = lookup(each.value, "availability_set_id", null)
  boot_diagnostics                                       = lookup(each.value, "boot_diagnostics", {})
  bypass_platform_safety_checks_on_user_schedule_enabled = lookup(each.value, "bypass_platform_safety_checks_on_user_schedule_enabled", false)
  capacity_reservation_group_id                          = lookup(each.value, "capacity_reservation_group_id", null)
  computer_name                                          = lookup(each.value, "computer_name", null)
  custom_data                                            = try(local.custom_data[each.key].custom_data, null)
  dedicated_host_id                                      = lookup(each.value, "dedicated_host_id", null)
  dedicated_host_group_id                                = lookup(each.value, "dedicated_host_group_id", null)
  disable_password_authentication                        = lookup(each.value, "disable_password_authentication", false)
  edge_zone                                              = lookup(each.value, "edge_zone", null)
  identity = {
    type         = each.value.identity.type
    identity_ids = each.value.identity.type == "UserAssigned" || each.value.identity.type == "SystemAssigned, UserAssigned" ? [module.user_assigned_identity[each.value.identity.identity].id] : null
  }
  provision_vm_agent     = lookup(each.value, "provision_vm_agent", true)
  source_image_id        = lookup(each.value, "source_image_id", null)
  source_image_reference = each.value.source_image_reference
  user_data              = lookup(each.value, "user_data", null)
  zone                   = lookup(each.value, "zone", null)
  ip_configuration       = merge(lookup(each.value, "ip_configuration", {}), local.linux_virtual_machine_ip_configuration[each.key])
  managed_disks          = each.value.managed_disks
  vm_extensions          = each.value.vm_extensions

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
output "linux_virtual_machine" {
  value = module.linux_virtual_machine
}