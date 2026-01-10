#--------
# Locals
#--------
helpers = {
  project          = "questopshub"
  project_short    = "qoh"
  environment      = "dev"
  region           = "centralus"
  region_short     = "cus"
  deployment       = "spoke"
  deployment_short = "sp"
  source           = "terraform"
  cost_center      = "6001"
  reason           = "JIRA-12345"
  created_by       = "veera-bhadra"
  team             = "infrateam"
  owner            = "veera-bhadra"
}

#----------------
# Resource Group
#----------------
resource_group = {
  network = {
    name = "rg-network"
  },
  compute = {
    name = "rg-compute"
  },
  security = {
    name = "rg-security"
  },
  database = {
    name = "rg-database"
  },
  management = {
    name = "rg-management"
  },
}

#-----------------
# Virtual Network
#-----------------
virtual_network = {
  default = {
    name           = "vnet"
    resource_group = "network"
    address_space  = ["34.0.0.0/16"]
    subnets = {
      default = {
        name              = "default"
        address_prefixes  = ["34.0.1.0/24"]
        service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
      },
    }
  },
}

#---------------------------------------
# Hub <-> Spoke Virtual Network Peering
#---------------------------------------
hub_spoke_peering = {
  hub_vnet                           = "default"
  spoke_vnet                         = "default"
  peer1_allow_virtual_network_access = true
  peer1_allow_forwarded_traffic      = true
  peer1_allow_gateway_transit        = true
  peer1_use_remote_gateways          = false
  peer2_allow_virtual_network_access = true
  peer2_allow_forwarded_traffic      = true
  peer2_allow_gateway_transit        = false
  peer2_use_remote_gateways          = false
}

#---------------
# User Identity
#---------------
user_assigned_identity = {
  app-lin = {
    name           = "id-app-lin"
    resource_group = "compute"
  },
  app-win = {
    name           = "id-app-win"
    resource_group = "compute"
  },
  func-lin = {
    name           = "id-func-lin"
    resource_group = "compute"
  },
  func-win = {
    name           = "id-func-win"
    resource_group = "compute"
  },
  st-func-lin = {
    name           = "id-st-func-lin"
    resource_group = "compute"
  },
  st-func-win = {
    name           = "id-st-func-win"
    resource_group = "compute"
  },
  cosmon = {
    name           = "id-cosmon"
    resource_group = "database"
  },
}

#-----------
# Key Vault
#-----------
key_vault = {
  default = {
    name                            = "kv"
    resource_group                  = "security"
    sku_name                        = "standard"
    access_policy                   = {}
    enabled_for_deployment          = false
    enabled_for_template_deployment = true
    enable_rbac_authorization       = false
    network_acls = {
      default_action      = "Allow" # @todo Set back to Deny
      bypass              = "AzureServices"
      ip_rules            = []
      private_link_access = {}
    }
    purge_protection_enabled      = true
    public_network_access_enabled = true
    soft_delete_retention_days    = 90
  },
}

#------------------
# Key Vault Secret
#------------------
key_vault_secret = {
  primary = {
    name      = "primary"
    value     = "primary"
    key_vault = "default"
  }
  secondary = {
    name      = "secondary"
    value     = "secondary"
    key_vault = "default"
  }
}

#-----------------
# Storage Account
#-----------------
storage_account = {
  # Storage Account used by the lin Function App(s)
  func-lin = {
    name                     = "st-func-lin"
    resource_group           = "compute"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    is_hns_enabled           = false
    nfsv3_enabled            = true
    identity = {
      type     = "UserAssigned"
      identity = "st-func-lin"
    }
    blob_properties  = {}
    queue_properties = {}
    share_properties = {}
    network_rules = {
      default_action      = "Allow" # @todo Set back to Deny
      bypass              = ["AzureServices", "Metrics"]
      ip_rules            = []
      private_link_access = {}
    }
  },
  # Storage Account used by the win Function App(s)
  func-win = {
    name                     = "st-func-win"
    resource_group           = "compute"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    is_hns_enabled           = false
    nfsv3_enabled            = true
    identity = {
      type     = "UserAssigned"
      identity = "st-func-win"
    }
    blob_properties  = {}
    queue_properties = {}
    share_properties = {}
    network_rules = {
      default_action      = "Allow" # @todo Set back to Deny
      bypass              = ["AzureServices", "Metrics"]
      ip_rules            = []
      private_link_access = {}
    }
  },
}

#-------------------
# Storage Container
#-------------------
storage_container = {
  default-func-lin = {
    name            = "default"
    storage_account = "func-lin"
  },
  default-func-win = {
    name            = "default"
    storage_account = "func-win"
  },
}

#--------------
# Service Plan
#--------------
service_plan = {
  "app-lin" = {
    name           = "asp-app-lin"
    resource_group = "compute"
    os_type        = "Linux"
    sku_name       = "P1v2"
  },
  "app-win" = {
    name           = "asp-app-win"
    resource_group = "compute"
    os_type        = "Windows"
    sku_name       = "P1v2"
  },
  "func-lin" = {
    name           = "asp-func-lin"
    resource_group = "compute"
    os_type        = "Linux"
    sku_name       = "P1v2"
  },
  "func-win" = {
    name           = "asp-func-win"
    resource_group = "compute"
    os_type        = "Windows"
    sku_name       = "P1v2"
  },
}

#----------------------
# Application Insights
#----------------------
application_insights = {
  "appi-app-lin" = {
    name             = "appi-app-lin"
    resource_group   = "management"
    application_type = "web"
  },
  "appi-app-win" = {
    name             = "appi-app-win"
    resource_group   = "management"
    application_type = "web"
  },
  "appi-func-lin" = {
    name             = "appi-func-lin"
    resource_group   = "management"
    application_type = "web"
  },
  "appi-func-win" = {
    name             = "appi-func-win"
    resource_group   = "management"
    application_type = "web"
  },
}

#---------------
# Linux Web App
#---------------
linux_web_app = {
  default = {
    name           = "app-lin"
    resource_group = "compute"
    service_plan   = "app-lin"
    https_only     = true
    identity = {
      type     = "UserAssigned"
      identity = "app-lin"
    }
    site_config = {
      always_on                               = true
      container_registry_use_managed_identity = true
      cors                                    = {}
      ftps_state                              = "Disabled"
      health_check_path                       = "/remoteEntry.js"
      health_check_eviction_time_in_min       = 5
      http2_enabled                           = true
      load_balancing_mode                     = "WeightedRoundRobin"
      minimum_tls_version                     = "1.2"
    }
    logs = {
      detailed_error_messages = false
      failed_request_tracing  = false
      http_logs = {
        file_system = {
          retention_in_days = 5
          retention_in_mb   = 25
        }
      }
    }
  },
}