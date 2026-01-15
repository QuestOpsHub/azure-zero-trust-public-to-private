#--------
# Locals
#--------
helpers = {
  project          = "questopshub"
  project_short    = "qoh"
  environment      = "prod"
  region           = "centralus"
  region_short     = "cus"
  deployment       = "hub"
  deployment_short = "hub"
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
    address_space  = ["30.0.0.0/16"]
    subnets = {
      default = {
        name              = "default"
        address_prefixes  = ["30.0.1.0/24"]
        service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
      },
      firewall = {
        name             = "AzureFirewallSubnet"
        address_prefixes = ["30.0.2.0/26"]
      },
      management = {
        name             = "AzureFirewallManagementSubnet"
        address_prefixes = ["30.0.2.64/26"]
      },
      vgw-er = {
        name             = "GatewaySubnet"
        address_prefixes = ["30.0.3.0/26"]
      },
      bastion = {
        name             = "AzureBastionSubnet"
        address_prefixes = ["30.0.4.0/26"]
      },
    }
  }
}

#------------------------
# User Assigned Identity
#------------------------
user_assigned_identity = {
  vm-lin = {
    name           = "id-vm-lin"
    resource_group = "security"
  },
  vm-win = {
    name           = "id-vm-win"
    resource_group = "security"
  },
  apim = {
    name           = "id-apim"
    resource_group = "security"
  },
  acr = {
    name           = "id-acr"
    resource_group = "security"
  },
}

#----------------------
# Application Insights
#----------------------
application_insights = {
  alpha = {
    name             = "appi"
    resource_group   = "management"
    application_type = "web"
  }
}

#----------------
# API Management
#----------------
api_management = {
  alpha = {
    name            = "apim"
    resource_group  = "integration"
    publisher_name  = "QuestOpsHub"
    publisher_email = "questopshub.microsoft_gmail.com#EXT#@questopshubmicrosoftgmail.onmicrosoft.com"
    sku_name        = "Basic_1"
    identity = {
      type     = "UserAssigned"
      identity = "apim"
    }
    security = {
      frontend_ssl30_enabled = true
    }
    public_network_access_enabled = true
    api_management_logger_name    = "apim-logger"
    identifier                    = "applicationinsights"
    always_log_errors             = true
    http_correlation_protocol     = "W3C"
    log_client_ip                 = true
    sampling_percentage           = 100.0
    verbosity                     = "information"
  },
}

#------------------
# Private Dns Zone
#------------------
# @todo Update `virtual_network_ids` after the Virtual Network is created.
private_dns_zone = {
  # Storage
  blob = {
    name           = "privatelink.blob.core.windows.net"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-jumpbox-cus-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-qoh-hub-jumpbox-cus/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-jumpbox-cus"
      }
    ]
  },
  table = {
    name           = "privatelink.table.core.windows.net"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-jumpbox-cus-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-qoh-hub-jumpbox-cus/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-jumpbox-cus"
      }
    ]
  },
  queue = {
    name           = "privatelink.queue.core.windows.net"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-jumpbox-cus-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-qoh-hub-jumpbox-cus/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-jumpbox-cus"
      }
    ]
  },
  file = {
    name           = "privatelink.file.core.windows.net"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-jumpbox-cus-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-qoh-hub-jumpbox-cus/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-jumpbox-cus"
      }
    ]
  },
  web = {
    name           = "privatelink.web.core.windows.net"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-jumpbox-cus-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-qoh-hub-jumpbox-cus/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-jumpbox-cus"
      }
    ]
  },
  # Web
  sites = {
    name           = "privatelink.azurewebsites.net" # Azure Web Apps / Azure Function Apps
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-jumpbox-cus-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-qoh-hub-jumpbox-cus/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-jumpbox-cus"
      }
    ]
  },
  # Security
  vault = {
    name           = "privatelink.vaultcore.azure.net"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-jumpbox-cus-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-qoh-hub-jumpbox-cus/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-jumpbox-cus"
      }
    ]
  },
  # Databases
  sqlServer = {
    name           = "privatelink.database.windows.net"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-jumpbox-cus-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-qoh-hub-jumpbox-cus/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-jumpbox-cus"
      }
    ]
  },
  Sql = {
    name           = "privatelink.documents.azure.com"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-jumpbox-cus-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-qoh-hub-jumpbox-cus/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-jumpbox-cus"
      }
    ]
  },
  managedInstance = {
    name           = "privatelink.managedInstance.windows.net"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-jumpbox-cus-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-qoh-hub-jumpbox-cus/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-jumpbox-cus"
      }
    ]
  },
  MongoDB = {
    name           = "privatelink.mongo.cosmos.azure.com"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-jumpbox-cus-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-qoh-hub-jumpbox-cus/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-jumpbox-cus"
      }
    ]
  },
  mysqlServer = {
    name           = "privatelink.mysql.database.azure.com"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-jumpbox-cus-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-qoh-hub-jumpbox-cus/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-jumpbox-cus"
      }
    ]
  },
  # Containers
  registry = {
    name           = "privatelink.azurecr.io"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-jumpbox-cus-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-qoh-hub-jumpbox-cus/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-jumpbox-cus"
      }
    ]
  },
  # Analytics
  dataFactory = {
    name           = "privatelink.datafactory.azure.net"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-jumpbox-cus-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-qoh-hub-jumpbox-cus/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-jumpbox-cus"
      }
    ]
  },
}

#------------------------
# Network Security Group
#------------------------
network_security_group = {
  bastion = {
    name            = "nsg-AzureBastionSubnet"
    resource_group  = "network"
    virtual_network = "alpha"
    subnet          = "bastion"
    inbound_rules = [
      {
        name                       = "AllowHttpsInbound"
        priority                   = 120
        access                     = "Allow"
        protocol                   = "Tcp"
        source_address_prefix      = "Internet"
        source_port_range          = "*"
        destination_address_prefix = "*"
        destination_port_ranges    = ["443"]
        description                = "AllowHttpsInbound"
      },
      {
        name                       = "AllowGatewayManagerInbound"
        priority                   = 130
        access                     = "Allow"
        protocol                   = "Tcp"
        source_address_prefix      = "GatewayManager"
        source_port_range          = "*"
        destination_address_prefix = "*"
        destination_port_ranges    = ["443"]
        description                = "AllowGatewayManagerInbound"
      },
      {
        name                       = "AllowAzureLoadBalancerInbound"
        priority                   = 140
        access                     = "Allow"
        protocol                   = "Tcp"
        source_address_prefix      = "AzureLoadBalancer"
        source_port_range          = "*"
        destination_address_prefix = "*"
        destination_port_ranges    = ["443"]
        description                = "AllowAzureLoadBalancerInbound"
      },
      {
        name                       = "AllowBastionHostCommunication"
        priority                   = 150
        access                     = "Allow"
        protocol                   = "*"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "*"
        destination_address_prefix = "VirtualNetwork"
        destination_port_ranges    = ["8080", "5701"]
        description                = "AllowBastionHostCommunication"
      }
    ]
    outbound_rules = [
      {
        name                       = "AllowSshRdpOutbound"
        priority                   = 100
        access                     = "Allow"
        protocol                   = "*"
        source_address_prefix      = "*"
        source_port_range          = "*"
        destination_address_prefix = "VirtualNetwork"
        destination_port_ranges    = ["22", "3389"]
        description                = "AllowSshRdpOutbound"
      },
      {
        name                       = "AllowAzureCloudOutbound"
        priority                   = 110
        access                     = "Allow"
        protocol                   = "Tcp"
        source_address_prefix      = "*"
        source_port_range          = "*"
        destination_address_prefix = "AzureCloud"
        destination_port_ranges    = ["443"]
        description                = "AllowAzureCloudOutbound"
      },
      {
        name                       = "AllowBastionCommunication"
        priority                   = 120
        access                     = "Allow"
        protocol                   = "*"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "*"
        destination_address_prefix = "VirtualNetwork"
        destination_port_ranges    = ["8080", "5701"]
        description                = "AllowBastionCommunication"
      },
      {
        name                       = "AllowHttpOutbound"
        priority                   = 130
        access                     = "Allow"
        protocol                   = "*"
        source_address_prefix      = "*"
        source_port_range          = "*"
        destination_address_prefix = "Internet"
        destination_port_ranges    = ["80"]
        description                = "AllowHttpOutbound"
      }
    ]
  },
  alpha = {
    name            = "nsg"
    resource_group  = "network"
    virtual_network = "alpha"
    subnet          = "default"
    inbound_rules = [
      {
        name                       = "AllowHTTPInbound"
        priority                   = 100
        access                     = "Allow"
        protocol                   = "Tcp"
        source_address_prefix      = "*"
        source_port_range          = "*"
        destination_address_prefix = "30.0.1.0/24" # default subnet address_prefixes
        destination_port_range     = "80"
        description                = "Allow HTTP traffic"
      },
      {
        name                       = "AllowHTTPSInbound"
        priority                   = 110
        access                     = "Allow"
        protocol                   = "Tcp"
        source_address_prefix      = "*"
        source_port_range          = "*"
        destination_address_prefix = "30.0.1.0/24" # default subnet address_prefixes
        destination_port_range     = "443"
        description                = "Allow HTTPS traffic"
      },
      {
        name                       = "AllowSSHInbound"
        priority                   = 120
        access                     = "Allow"
        protocol                   = "Tcp"
        source_address_prefix      = "*"
        source_port_range          = "*"
        destination_address_prefix = "30.0.1.0/24" # default subnet address_prefixes
        destination_port_range     = "22"
        description                = "Allow SSH access for Linux VMs"
      },
      {
        name                       = "AllowRDPInbound"
        priority                   = 130
        access                     = "Allow"
        protocol                   = "Tcp"
        source_address_prefix      = "*"
        source_port_range          = "*"
        destination_address_prefix = "30.0.1.0/24" # default subnet address_prefixes
        destination_port_range     = "3389"
        description                = "Allow RDP access for Windows VMs"
      },
    ]
    outbound_rules = [
      {
        name                       = "AllowAllOutbound"
        priority                   = 100
        access                     = "Allow"
        protocol                   = "*"
        source_address_prefix      = "*"
        source_port_range          = "*"
        destination_address_prefix = "*"
        destination_port_range     = "*"
        description                = "Allow all outbound traffic"
      },
    ]
  }
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
key_vault_secret = {
  alpha = {
    name      = "alpha"
    value     = "alpha"
    key_vault = "alpha"
  }
  beta = {
    name      = "beta"
    value     = "beta"
    key_vault = "alpha"
  }
}

#-----------
# Public IP
#-----------
public_ip = {
  alpha = {
    name              = "ip-bas"
    resource_group    = "network"
    allocation_method = "Static"
    sku               = "Standard"
    sku_tier          = "Regional"
  },
}

#--------------
# Bastion Host
#--------------
bastion_host = {
  alpha = {
    name           = "bas"
    resource_group = "compute"
    sku            = "Standard"
    ip_configuration = {
      name = "bastionHostConfig"
    }
    tunneling_enabled = true
  },
}

#-----------------------
# Linux Virtual Machine
#-----------------------
linux_virtual_machine = {
  alpha = {
    name           = "vm-lin-jb"
    resource_group = "compute"
    license_type   = null
    size           = "Standard_B2s"
    os_disk = {
      caching              = "ReadWrite"
      storage_account_type = "StandardSSD_LRS"
      disk_size_gb         = "30"
    }
    allow_extension_operations = true
    custom_data                = null
    identity = {
      type     = "UserAssigned"
      identity = "vm-lin"
    }
    provision_vm_agent = true
    source_image_id    = null
    source_image_reference = {
      publisher = "canonical"
      offer     = "0001-com-ubuntu-server-focal"
      sku       = "20_04-lts-gen2"
      version   = "latest"
    }
    user_data       = null
    zone            = 1
    virtual_network = "alpha"
    subnet          = "default"
    ip_configuration = {
      name                          = "linuxVirtualMachineConfig"
      private_ip_address_version    = "IPv4"
      private_ip_address_allocation = "Dynamic"
      primary                       = true
    }
    managed_disks = {
      "disk01" = {
        storage_account_type = "Standard_LRS"
        create_option        = "Empty"
        disk_size_gb         = "10"
        edge_zone            = null
        zone                 = 1
        lun                  = "10"
        caching              = "ReadWrite"
      },
      "disk02" = {
        storage_account_type = "Standard_LRS"
        create_option        = "Empty"
        disk_size_gb         = "10"
        edge_zone            = null
        zone                 = 1
        lun                  = "20"
        caching              = "ReadWrite"
      },
      "disk03" = {
        storage_account_type = "Standard_LRS"
        create_option        = "Empty"
        disk_size_gb         = "10"
        edge_zone            = null
        zone                 = 1
        lun                  = "30"
        caching              = "ReadWrite"
      },
      "disk04" = {
        storage_account_type = "Standard_LRS"
        create_option        = "Empty"
        disk_size_gb         = "10"
        edge_zone            = null
        zone                 = 1
        lun                  = "40"
        caching              = "ReadWrite"
      },
    }
    vm_extensions = {
      "Nginx" = {
        name                 = "Nginx"
        publisher            = "Microsoft.Azure.Extensions"
        type                 = "CustomScript"
        type_handler_version = "2.0"
        settings             = <<SETTINGS
{
 "commandToExecute": "sudo apt-get update && sudo apt-get install nginx -y && echo \"<html><body style='background-color:blue'><h1>Hello World from $(hostname)</h1></body></html>\" > /var/www/html/index.html && sudo systemctl restart nginx"
}
SETTINGS
      }
    }
  },
}

#-------------------------
# Windows Virtual Machine
#-------------------------
windows_virtual_machine = {
  alpha = {
    name           = "vm-win-jb"
    resource_group = "compute"
    size           = "Standard_DS3_v2"
    license_type   = null
    os_disk = {
      caching              = "ReadWrite"
      storage_account_type = "StandardSSD_LRS"
      disk_size_gb         = "30"
    }
    allow_extension_operations = true
    custom_data                = null
    edge_zone                  = null
    identity = {
      type     = "UserAssigned"
      identity = "vm-win"
    }
    provision_vm_agent = true
    source_image_id    = null
    source_image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter"
      version   = "latest"
    }
    user_data    = null
    vtpm_enabled = null
    zone         = null
    managed_disks = {
      disk01 = {
        storage_account_type = "Standard_LRS"
        create_option        = "Empty"
        disk_size_gb         = "10"
        lun                  = "10"
        caching              = "ReadWrite"
      },
    }
  }
}

#--------------------
# Container Registry
#--------------------
container_registry = {
  alpha = {
    name           = "acr"
    resource_group = "container"
    sku            = "Standard"
    identity = {
      type     = "UserAssigned"
      identity = "acr"
    }
  }
}