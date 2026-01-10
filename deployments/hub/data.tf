data "azurerm_client_config" "current" {}

data "azuread_user" "admin_user" {
  user_principal_name = "questopshub.microsoft_gmail.com#EXT#@questopshubmicrosoftgmail.onmicrosoft.com"
}

data "azuread_service_principal" "hub_service_principal" {
  display_name = "hub_service_principal"
}