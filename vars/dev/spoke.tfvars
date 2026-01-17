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
  ai = {
    name = "rg-ai"
  },
  analytics = {
    name = "rg-analytics"
  },
  compute = {
    name = "rg-compute"
  },
  container = {
    name = "rg-container"
  },
  database = {
    name = "rg-database"
  },
  devops = {
    name = "rg-devops"
  },
  integration = {
    name = "rg-integration"
  },
  management = {
    name = "rg-management"
  },
  network = {
    name = "rg-network"
  },
  security = {
    name = "rg-security"
  },
  storage = {
    name = "rg-storage"
  }
}

#-----------------
# Virtual Network
#-----------------
virtual_network = {
  alpha = {
    name           = "vnet"
    resource_group = "network"
    address_space  = ["34.0.0.0/16"]
    subnets = {
      default = {
        name             = "default"
        address_prefixes = ["34.0.1.0/24"]
        service_endpoints = [
          "Microsoft.KeyVault",
          "Microsoft.Storage"
        ]
      },
      # MSSQL Managed Instance requires a delegated subnet
      sql = {
        name             = "snet-sql"
        address_prefixes = ["34.0.2.0/26"]
        delegation = {
          managed_instance = {
            name = "managedinstancedelegation"
            service_delegation = {
              name = "Microsoft.Sql/managedInstances"
              actions = [
                "Microsoft.Network/virtualNetworks/subnets/join/action",
                "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
                "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
              ]
            }
          }
        }
      },
    }
  }
}

#---------------------------------------
# Hub <-> Spoke Virtual Network Peering
#---------------------------------------
hub_spoke_peering = {
  hub_vnet                           = "alpha"
  spoke_vnet                         = "alpha"
  peer1_allow_virtual_network_access = true
  peer1_allow_forwarded_traffic      = true
  peer1_allow_gateway_transit        = true
  peer1_use_remote_gateways          = false
  peer2_allow_virtual_network_access = true
  peer2_allow_forwarded_traffic      = true
  peer2_allow_gateway_transit        = false
  peer2_use_remote_gateways          = false
}

#------------------------
# User Assigned Identity
#------------------------
user_assigned_identity = {
  app-lin = {
    name           = "id-app-lin"
    resource_group = "security"
  },
  app-win = {
    name           = "id-app-win"
    resource_group = "security"
  },
  func-lin = {
    name           = "id-func-lin"
    resource_group = "security"
  },
  func-win = {
    name           = "id-func-win"
    resource_group = "security"
  },
  st-func-lin = {
    name           = "id-st-func-lin"
    resource_group = "security"
  },
  st-func-win = {
    name           = "id-st-func-win"
    resource_group = "security"
  },
  cosmon = {
    name           = "id-cosmon"
    resource_group = "security"
  },
  sql = {
    name           = "id-sql"
    resource_group = "security"
  },
  sqlmi = {
    name           = "id-sqlmi"
    resource_group = "security"
  },
}

#-----------
# Key Vault
#-----------
key_vault = {
  alpha = {
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
key_vault_secret = {}

#-----------------
# Storage Account
#-----------------
storage_account = {
  # Storage Account used by the Linux Function App(s)
  alpha = {
    name                     = "st-func-lin"
    resource_group           = "storage"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    is_hns_enabled           = false
    nfsv3_enabled            = true
    identity = {
      type     = "UserAssigned"
      identity = "st-func-lin"
    }
    blob_properties = {
      cors_rule = {
        allowed_headers    = ["*"]
        allowed_methods    = ["GET"]
        allowed_origins    = ["https://*.lightmetrics.co", "https://*.detroitconnect.com", "http://localhost:4300"]
        exposed_headers    = ["x-ms-meta-*"]
        max_age_in_seconds = "200"
      }
      versioning_enabled = true
    }
    queue_properties = {
      cors_rule = {
        allowed_headers    = ["*"]
        allowed_methods    = ["GET", "OPTIONS"]
        allowed_origins    = ["https://myhost.com"]
        exposed_headers    = ["*"]
        max_age_in_seconds = "200"
      }
    }
    share_properties = {
      cors_rule = {
        allowed_headers    = ["*"]
        allowed_methods    = ["GET"]
        allowed_origins    = ["https://myhost.com"]
        exposed_headers    = ["x-ms-meta-*"]
        max_age_in_seconds = "200"
      }
    }
    network_rules = {
      default_action      = "Allow" # @todo Set back to Deny
      bypass              = ["AzureServices", "Metrics"]
      ip_rules            = []
      private_link_access = {}
    }
  },
  # Storage Account used by the Windows Function App(s)
  beta = {
    name                     = "st-func-win"
    resource_group           = "storage"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    is_hns_enabled           = false
    nfsv3_enabled            = true
    identity = {
      type     = "UserAssigned"
      identity = "st-func-win"
    }
    blob_properties = {
      cors_rule = {
        allowed_headers    = ["*"]
        allowed_methods    = ["GET"]
        allowed_origins    = ["https://*.lightmetrics.co", "https://*.detroitconnect.com", "http://localhost:4300"]
        exposed_headers    = ["x-ms-meta-*"]
        max_age_in_seconds = "200"
      }
      versioning_enabled = true
    }
    queue_properties = {
      cors_rule = {
        allowed_headers    = ["*"]
        allowed_methods    = ["GET", "OPTIONS"]
        allowed_origins    = ["https://myhost.com"]
        exposed_headers    = ["*"]
        max_age_in_seconds = "200"
      }
    }
    share_properties = {
      cors_rule = {
        allowed_headers    = ["*"]
        allowed_methods    = ["GET"]
        allowed_origins    = ["https://myhost.com"]
        exposed_headers    = ["x-ms-meta-*"]
        max_age_in_seconds = "200"
      }
    }
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
  default-st-alpha = {
    name            = "default"
    storage_account = "alpha"
  },
  default-st-beta = {
    name            = "default"
    storage_account = "beta"
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
  alpha = {
    name           = "app-lin"
    resource_group = "compute"
    service_plan   = "app-lin"
    https_only     = true
    identity = {
      type     = "UserAssigned"
      identity = "app-lin"
    }
    site_config = {
      always_on = true
      # application_stack = {
      #   docker_image_name   = "acrhubcus01.azurecr.io/dvs-core-dcp-client-vehicle-history-dev-cus-01:1.0.0"
      #   docker_registry_url = "https://acrhubcus01.azurecr.io"
      # }
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

#--------------------
# Linux Function App
#--------------------
linux_function_app = {
  alpha = {
    name           = "func-lin-node"
    resource_group = "compute"
    service_plan   = "func-lin"
    site_config = {
      always_on = true
      application_stack = {
        node_version = "18"
      }
      cors                              = {}
      ftps_state                        = "Disabled"
      health_check_path                 = "/remoteEntry.js"
      health_check_eviction_time_in_min = 5
      http2_enabled                     = true
      ip_restriction = {
        all_traffic = {
          action     = "Allow"
          ip_address = "0.0.0.0/0"
        }
      }
      load_balancing_mode = "WeightedRoundRobin"
      minimum_tls_version = "1.2"
      scm_ip_restriction = {
        all_traffic = {
          action     = "Allow"
          ip_address = "0.0.0.0/0"
        }
      }
    }
    app_settings = {}
    identity = {
      type     = "UserAssigned"
      identity = "func-lin"
    }
    storage_account = "alpha"
  },
  beta = {
    name           = "func-lin-java"
    resource_group = "compute"
    service_plan   = "func-lin"
    site_config = {
      always_on = true
      application_stack = {
        java_version = "17"
      }
      cors                              = {}
      ftps_state                        = "Disabled"
      health_check_path                 = "/api/health"
      health_check_eviction_time_in_min = 5
      http2_enabled                     = true
      ip_restriction = {
        all_traffic = {
          action     = "Allow"
          ip_address = "0.0.0.0/0"
        }
      }
      load_balancing_mode = "WeightedRoundRobin"
      minimum_tls_version = "1.2"
      scm_ip_restriction = {
        all_traffic = {
          action     = "Allow"
          ip_address = "0.0.0.0/0"
        }
      }
    }
    app_settings = {}
    identity = {
      type     = "UserAssigned"
      identity = "func-lin"
    }
    storage_account = "beta"
  },
}

#------------------
# CosmosDB Account
#------------------
cosmosdb_account = {
  alpha = {
    name           = "cosmon"
    resource_group = "database"
    offer_type     = "Standard"
    kind           = "MongoDB"
    consistency_policy = {
      consistency_level       = "BoundedStaleness"
      max_interval_in_seconds = 300
      max_staleness_prefix    = 100000
    }
    geo_location = {
      eastus = {
        location          = "eastus"
        failover_priority = 1
        zone_redundant    = false
      },
      westus = {
        location          = "westus"
        failover_priority = 0
        zone_redundant    = false
      }
    }
    automatic_failover_enabled    = true
    public_network_access_enabled = true
    capabilities = [
      "EnableAggregationPipeline",
      "mongoEnableDocLevelTTL",
      "MongoDBv3.4",
      "EnableMongo"
    ]
    backup = {
      type = "Periodic"
    }
    identity = {
      type     = "UserAssigned"
      identity = "cosmon"
    }
  },
}

#--------------
# MSSQL Server
#--------------
mssql_server = {
  alpha = {
    name                 = "sql"
    resource_group       = "database"
    mssql_server_version = "12.0"
    azuread_administrator = {
      azuread_authentication_only = false
    }
    connection_policy = "Default"
    identity = {
      type     = "UserAssigned"
      identity = "sql"
    }
  },
}

#----------------
# MSSQL Database
#----------------
mssql_database = {
  alpha = {
    name         = "sqldb"
    mssql_server = "alpha"
  },
}

#------------------------
# MSSQL Managed Instance
#------------------------
mssql_managed_instance = {
  alpha = {
    name               = "sqlmi"
    resource_group     = "database"
    license_type       = "BasePrice"
    sku_name           = "GP_Gen5"
    storage_size_in_gb = "64"
    subnet             = "sql"
    vcores             = "8"
    identity = {
      type     = "UserAssigned"
      identity = "sqlmi"
    }
  },
}

#------------------------
# MSSQL Managed Database
#------------------------
mssql_managed_database = {
  alpha = {
    name                   = "sqlmdb"
    mssql_managed_instance = "alpha"
  },
}

#-------------------
# Private End Point
#-------------------
private_endpoint = {
  cosmon-alpha = {
    name                   = "pep-cosmon-alpha"
    resource_group         = "network"
    private_dns_zone_group = {}
    private_service_connection = {
      is_manual_connection              = false
      private_connection_resource_alias = null
      subresource_names                 = ["MongoDB"]
      request_message                   = "PL"
    }
  },
  kv-alpha = {
    name                   = "pep-kv-alpha"
    resource_group         = "network"
    private_dns_zone_group = {}
    private_service_connection = {
      is_manual_connection              = false
      private_connection_resource_alias = null
      subresource_names                 = ["vault"]
      request_message                   = "PL"
    }
  },
  st-alpha = {
    name                   = "pep-st-alpha"
    resource_group         = "network"
    private_dns_zone_group = {}
    private_service_connection = {
      is_manual_connection              = false
      private_connection_resource_alias = null
      subresource_names                 = ["blob"]
      request_message                   = "PL"
    }
  },
  st-beta = {
    name                   = "pep-st-beta"
    resource_group         = "network"
    private_dns_zone_group = {}
    private_service_connection = {
      is_manual_connection              = false
      private_connection_resource_alias = null
      subresource_names                 = ["blob"]
      request_message                   = "PL"
    }
  },
  app-alpha = {
    name                   = "pep-app-alpha"
    resource_group         = "network"
    private_dns_zone_group = {}
    private_service_connection = {
      is_manual_connection              = false
      private_connection_resource_alias = null
      subresource_names                 = ["sites"]
      request_message                   = "PL"
    }
  },
  func-alpha = {
    name                   = "pep-func-alpha"
    resource_group         = "network"
    private_dns_zone_group = {}
    private_service_connection = {
      is_manual_connection              = false
      private_connection_resource_alias = null
      subresource_names                 = ["sites"]
      request_message                   = "PL"
    }
  },
  func-beta = {
    name                   = "pep-func-beta"
    resource_group         = "network"
    private_dns_zone_group = {}
    private_service_connection = {
      is_manual_connection              = false
      private_connection_resource_alias = null
      subresource_names                 = ["sites"]
      request_message                   = "PL"
    }
  },
  sql-alpha = {
    name                   = "pep-sql-alpha"
    resource_group         = "network"
    private_dns_zone_group = {}
    private_service_connection = {
      is_manual_connection              = false
      private_connection_resource_alias = null
      subresource_names                 = ["sqlServer"]
      request_message                   = "PL"
    }
  },
}