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
  network = {
    name = "rg-network"
  },
  compute = {
    name = "rg-compute"
  },
}

#-----------------
# Virtual Network
#-----------------
virtual_network = {
  default = {
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

#---------------
# User Identity
#---------------
user_assigned_identity = {
  vm-lin = {
    name           = "id-vm-lin"
    resource_group = "compute"
  },
  vm-win = {
    name           = "id-vm-win"
    resource_group = "compute"
  },
}

#------------------
# Private Dns Zone
#------------------
# @todo Update `virtual_network_ids` after the Virtual Network is created.
private_dns_zone = {
  sqlServer = {
    name           = "privatelink.database.windows.net"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-prod-cus-4k6f-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-network-qoh-hub-prod-cus-4k6f/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-prod-cus-4k6f"
      }
    ]
  },
  blob = {
    name           = "privatelink.blob.core.windows.net"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-prod-cus-4k6f-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-network-qoh-hub-prod-cus-4k6f/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-prod-cus-4k6f"
      }
    ]
  },
  vault = {
    name           = "privatelink.vaultcore.azure.net"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-prod-cus-4k6f-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-network-qoh-hub-prod-cus-4k6f/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-prod-cus-4k6f"
      }
    ]
  },
  registry = {
    name           = "privatelink.azurecr.io"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-prod-cus-4k6f-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-network-qoh-hub-prod-cus-4k6f/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-prod-cus-4k6f"
      }
    ]
  },
  dataFactory = {
    name           = "privatelink.datafactory.azure.net"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-prod-cus-4k6f-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-network-qoh-hub-prod-cus-4k6f/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-prod-cus-4k6f"
      }
    ]
  },
  MongoDB = {
    name           = "privatelink.mongo.cosmos.azure.com"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-prod-cus-4k6f-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-network-qoh-hub-prod-cus-4k6f/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-prod-cus-4k6f"
      }
    ]
  },
  Sql = {
    name           = "privatelink.documents.azure.com"
    resource_group = "network"
    virtual_network_ids = [
      {
        name    = "dns-vnet-qoh-hub-prod-cus-4k6f-link"
        vnet_id = "/subscriptions/ba143abd-03c0-43fc-bb1f-5bf74803b418/resourceGroups/rg-network-qoh-hub-prod-cus-4k6f/providers/Microsoft.Network/virtualNetworks/vnet-qoh-hub-prod-cus-4k6f"
      }
    ]
  },
}

#------------------------
# Network Security Group
#------------------------
network_security_group = {
  # Bastion
  bastion = {
    name            = "nsg-AzureBastionSubnet"
    resource_group  = "network"
    virtual_network = "default"
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
  default = {
    name            = "nsg-default"
    resource_group  = "network"
    virtual_network = "default"
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
# Public IP
#-----------
public_ip = {
  bastion = {
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
  default = {
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
  jumpbox = {
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
    virtual_network = "default"
    subnet          = "default"
    ip_configuration = {
      name                          = "linuxVirtualMachineConfig"
      private_ip_address_version    = "IPv4"
      private_ip_address_allocation = "Dynamic"
      primary                       = true
    }
    managed_disks = {}
    vm_extensions = {}
  },
}