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

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
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

#---------
# Backend 
#---------
terraform {
  backend "azurerm" {}
}

#-------------
# Hub Backend
#-------------
data "terraform_remote_state" "hub" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-qoh-tf-backend-cus"
    storage_account_name = "stqohtfbackendcus9284"
    container_name       = "hub-tfstate"
    key                  = "prod/hub.prod.tfstate"
    subscription_id      = var.hub_subscription_id
    access_key           = data.azurerm_storage_account.storage_account.primary_access_key
  }
}