#-----------------
# Storage Account
#-----------------
data "azurerm_storage_account" "storage_account" {
  provider            = azurerm.hub
  name                = "stqohtfbackendcus9284"
  resource_group_name = "rg-qoh-tf-backend-cus"
}

data "azurerm_client_config" "current" {}

data "azuread_user" "admin_user" {
  user_principal_name = "questopshub.microsoft_gmail.com#EXT#@questopshubmicrosoftgmail.onmicrosoft.com"
}

data "azuread_service_principal" "spoke_service_principal" {
  display_name = "spoke_service_principal"
}
