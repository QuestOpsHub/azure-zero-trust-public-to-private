#-------------------
# Private End Point
#-------------------
locals {
  private_dns_zone_group = {
    cosmon-alpha = {
      name                 = data.terraform_remote_state.hub.outputs.private_dns_zone["Sql"].name
      private_dns_zone_ids = [data.terraform_remote_state.hub.outputs.private_dns_zone["Sql"].id]
    }
    kv-alpha = {
      name                 = data.terraform_remote_state.hub.outputs.private_dns_zone["vault"].name
      private_dns_zone_ids = [data.terraform_remote_state.hub.outputs.private_dns_zone["vault"].id]
    }
    st-alpha = {
      name                 = data.terraform_remote_state.hub.outputs.private_dns_zone["blob"].name
      private_dns_zone_ids = [data.terraform_remote_state.hub.outputs.private_dns_zone["blob"].id]
    }
    st-beta = {
      name                 = data.terraform_remote_state.hub.outputs.private_dns_zone["blob"].name
      private_dns_zone_ids = [data.terraform_remote_state.hub.outputs.private_dns_zone["blob"].id]
    }
    app-alpha = {
      name                 = data.terraform_remote_state.hub.outputs.private_dns_zone["sites"].name
      private_dns_zone_ids = [data.terraform_remote_state.hub.outputs.private_dns_zone["sites"].id]
    }
    func-alpha = {
      name                 = data.terraform_remote_state.hub.outputs.private_dns_zone["sites"].name
      private_dns_zone_ids = [data.terraform_remote_state.hub.outputs.private_dns_zone["sites"].id]
    }
    func-beta = {
      name                 = data.terraform_remote_state.hub.outputs.private_dns_zone["sites"].name
      private_dns_zone_ids = [data.terraform_remote_state.hub.outputs.private_dns_zone["sites"].id]
    }
    sql-alpha = {
      name                 = data.terraform_remote_state.hub.outputs.private_dns_zone["Sql"].name
      private_dns_zone_ids = [data.terraform_remote_state.hub.outputs.private_dns_zone["Sql"].id]
    }
  }
  private_service_connection = {
    cosmon-alpha = {
      name                           = "${module.cosmosdb_account["alpha"].name}-privateserviceconnection"
      private_connection_resource_id = module.cosmosdb_account["alpha"].id
    }
    kv-alpha = {
      name                           = "${module.key_vault["alpha"].name}-privateserviceconnection"
      private_connection_resource_id = module.key_vault["alpha"].id
    }
    st-alpha = {
      name                           = "${module.storage_account["alpha"].name}-privateserviceconnection"
      private_connection_resource_id = module.storage_account["alpha"].id
    }
    st-beta = {
      name                           = "${module.storage_account["beta"].name}-privateserviceconnection"
      private_connection_resource_id = module.storage_account["beta"].id
    }
    app-alpha = {
      name                           = "${module.linux_web_app["alpha"].name}-privateserviceconnection"
      private_connection_resource_id = module.linux_web_app["alpha"].id
    }
    func-alpha = {
      name                           = "${module.linux_function_app["alpha"].name}-privateserviceconnection"
      private_connection_resource_id = module.linux_function_app["alpha"].id
    }
    func-beta = {
      name                           = "${module.linux_function_app["beta"].name}-privateserviceconnection"
      private_connection_resource_id = module.linux_function_app["beta"].id
    }
    sql-alpha = {
      name                           = "${module.mssql_server["alpha"].name}-privateserviceconnection"
      private_connection_resource_id = module.mssql_server["alpha"].id
    }
  }
}

module "private_endpoint" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-private-endpoint.git?ref=v1.0.0"

  for_each                      = var.private_endpoint
  name                          = "${each.value.name}-${local.resource_suffix}"
  resource_group_name           = module.resource_group[each.value.resource_group].name
  location                      = var.helpers.region
  subnet_id                     = module.virtual_network["alpha"].subnets["default"].id
  custom_network_interface_name = lookup(each.value, "custom_network_interface_name", null)
  private_dns_zone_group = merge(
    lookup(each.value, "private_dns_zone_group", {}),
    local.private_dns_zone_group[each.key]
  )
  private_service_connection = merge(
    lookup(each.value, "private_service_connection", {}),
    local.private_service_connection[each.key]
  )
  ip_configuration = lookup(each.value, "ip_configuration", {})

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}