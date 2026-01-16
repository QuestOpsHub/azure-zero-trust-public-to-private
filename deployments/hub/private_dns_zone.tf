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

#------------------
# Private Dns Zone
#------------------
variable "private_dns_zone" {}

#---------
# Outputs
#---------
output "private_dns_zone" {
  value = module.private_dns_zone
}