#--------------------
# Required Providers
#--------------------
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.0.0"
    }
  }
  required_version = ">=0.13"
}

provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  features {}
}

#---------------
# Hub Providers
#---------------
provider "azurerm" {
  alias           = "hub"
  subscription_id = var.hub_subscription_id
  client_id       = var.hub_client_id
  client_secret   = var.hub_client_secret
  tenant_id       = var.tenant_id
  features {}
}