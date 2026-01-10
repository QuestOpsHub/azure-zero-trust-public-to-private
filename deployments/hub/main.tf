#---------
# Backend 
#---------
terraform {
  backend "azurerm" {}
}

#---------------
# Random String
#---------------
module "random_string" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-random-string.git?ref=v1.0.0"

  length  = 4
  lower   = true
  numeric = true
  special = false
  upper   = false
}

#----------------
# Resource Group
#----------------
module "resource_group" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-resource-group.git?ref=v1.0.0"

  for_each   = var.resource_group
  name       = "${each.value.name}-${local.resource_suffix}"
  location   = var.helpers.region
  managed_by = lookup(each.value, "managed_by", null)

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

#-----------------
# Virtual Network
#-----------------
module "virtual_network" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-virtual-network.git?ref=v1.0.0"

  for_each                = var.virtual_network
  name                    = "${each.value.name}-${local.resource_suffix}-${module.random_string.result}"
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

#------------------------
# User Assigned Identity
#------------------------
module "user_assigned_identity" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-user-assigned-identity.git?ref=v1.0.0"

  for_each            = var.user_assigned_identity
  name                = "${each.value.name}-${local.resource_suffix}-${module.random_string.result}"
  location            = var.helpers.region
  resource_group_name = module.resource_group[each.value.resource_group].name

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

#----------------------
# Application Insights
#----------------------
module "application_insights" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-application-insights.git?ref=v1.0.1"

  for_each                              = var.application_insights
  name                                  = "${each.value.name}-${local.resource_suffix}-${module.random_string.result}"
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

#----------------
# API Management
#----------------
# @todo add all supported arguments
module "api_management" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-api-management.git?ref=v1.0.1"

  for_each            = var.api_management
  name                = each.value.name
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
  instrumentation_key           = module.application_insights["alpha"].instrumentation_key
  identifier                    = each.value.identifier
  sampling_percentage           = each.value.sampling_percentage
  always_log_errors             = each.value.always_log_errors
  log_client_ip                 = each.value.log_client_ip
  verbosity                     = each.value.verbosity
  http_correlation_protocol     = each.value.http_correlation_protocol

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

#------------------
# Private Dns Zone
#------------------
# Note: The for_each argument in the module requires a list of objects that are fully known before the apply stage.
# To ensure successful execution, un-comment the following block of code only after the `module.virtual_network` is deployed.
# locals {
#   virtual_network_ids = [
#     {
#       name    = "dns-${module.virtual_network["network"].name}-link"
#       vnet_id = module.virtual_network["network"].id
#     }
#   ]
# }

module "private_dns_zone" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-private-dns-zone.git?ref=v1.0.1"

  for_each            = var.private_dns_zone
  name                = each.value.name
  resource_group_name = module.resource_group[each.value.resource_group].name
  soa_record          = lookup(each.value, "soa_record", {})
  # virtual_network_ids = distinct(concat(local.virtual_network_ids, lookup(each.value, "virtual_network_ids", [])))
  virtual_network_ids = lookup(each.value, "virtual_network_ids", [])

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

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

#-----------
# Key Vault
#-----------
locals {
  key_vault_access_policy = {
    alpha = {
      admin_user = {
        object_id               = data.azuread_user.admin_user.object_id
        key_permissions         = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
        secret_permissions      = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
        certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
        storage_permissions     = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"]
      },
      hub_service_principal = {
        object_id               = data.azuread_service_principal.hub_service_principal.object_id
        key_permissions         = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
        secret_permissions      = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
        certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
        storage_permissions     = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"]
      },
    },
  }
  key_vault_network_acls = {
    alpha = {
      subnet_details = {
        default = {
          vnet_rg_name = module.virtual_network["alpha"].resource_group_name
          vnet_name    = module.virtual_network["alpha"].name
          subnet_name  = module.virtual_network["alpha"].subnets["default"].name
        },
      }
    },
  }
}

module "key_vault" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-key-vault.git?ref=v1.0.0"

  for_each                        = var.key_vault
  name                            = "${each.value.name}-${local.resource_suffix}-${module.random_string.result}"
  location                        = var.helpers.region
  resource_group_name             = module.resource_group[each.value.resource_group].name
  sku_name                        = each.value.sku_name
  access_policy                   = merge(lookup(each.value, "access_policy", {}), local.key_vault_access_policy[each.key])
  enabled_for_deployment          = lookup(each.value, "enabled_for_deployment", null)
  enabled_for_disk_encryption     = lookup(each.value, "enabled_for_disk_encryption", null)
  enabled_for_template_deployment = lookup(each.value, "enabled_for_template_deployment", null)
  enable_rbac_authorization       = lookup(each.value, "enable_rbac_authorization", null)
  network_acls                    = merge(lookup(each.value, "network_acls", {}), local.key_vault_network_acls[each.key])
  purge_protection_enabled        = lookup(each.value, "purge_protection_enabled", null)
  public_network_access_enabled   = lookup(each.value, "public_network_access_enabled", true)
  soft_delete_retention_days      = lookup(each.value, "soft_delete_retention_days", null)

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      owner = lookup(var.key_vault, "resource_tags", local.resource_tags).owner
      team  = lookup(var.key_vault, "resource_tags", local.resource_tags).team
    }
  )
}

#------------------
# Key Vault Secret
#------------------
module "key_vault_secret" {
  depends_on = [module.key_vault]
  source     = "git::https://github.com/QuestOpsHub/terraform-azurerm-key-vault-secret.git?ref=v1.0.0"

  for_each        = var.key_vault_secret
  name            = each.value.name
  value           = each.value.value
  key_vault_id    = module.key_vault[each.value.key_vault].id
  content_type    = lookup(each.value, "content_type", null)
  not_before_date = lookup(each.value, "not_before_date", null)
  expiration_date = lookup(each.value, "expiration_date", null)

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

#-----------
# Public IP
#-----------
module "public_ip" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-public-ip.git?ref=v1.0.0"

  for_each                = var.public_ip
  name                    = "${each.value.name}-${local.resource_suffix}-${module.random_string.result}"
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
  name                      = "${each.value.name}-${local.resource_suffix}-${module.random_string.result}"
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
  name                                                   = "${each.value.name}-${local.resource_suffix}-${module.random_string.result}"
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