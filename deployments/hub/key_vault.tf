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
  name                            = "${each.value.name}-${local.resource_suffix}"
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
resource "random_string" "kv_secret" {
  for_each = var.key_vault_secret

  length  = 8
  upper   = false
  special = false

  keepers = {
    secret_key = each.key
  }
}

locals {
  key_vault_secret_final = {
    for k, v in var.key_vault_secret :
    k => {
      key_vault = v.key_vault
      name      = k
      value     = "${k}-${local.time_compact_utc}-${random_string.kv_secret[k].result}"
    }
  }
}

module "key_vault_secret" {
  depends_on = [module.key_vault]
  source     = "git::https://github.com/QuestOpsHub/terraform-azurerm-key-vault-secret.git?ref=v1.0.0"

  for_each        = local.key_vault_secret_final
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

#---------
# Outputs
#---------
output "key_vault" {
  value = module.key_vault
}

output "key_vault_secret" {
  value = module.key_vault_secret
}