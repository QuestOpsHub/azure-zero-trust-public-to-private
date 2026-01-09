locals {
  timestamp           = timestamp()
  timestamp_sanitized = formatdate("DD MMM YYYY hh:mm ZZZ", local.timestamp)
  timestamp_tag = {
    creation_timestamp = local.timestamp_sanitized
  }
  resource_suffix = "${var.helpers.project_short}-${var.helpers.deployment_short}-${var.helpers.environment}-${var.helpers.region_short}"
  common_tags = {
    project     = var.helpers.project
    environment = var.helpers.environment
    region      = var.helpers.region
    source      = var.helpers.source
    cost_center = var.helpers.cost_center
    reason      = var.helpers.reason
    created_by  = var.helpers.created_by
    deployment  = var.helpers.deployment
  }
  resource_tags = {
    team  = var.helpers.team
    owner = var.helpers.owner
  }
}