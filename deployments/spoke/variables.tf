#--------------------
# Required Providers
#--------------------
variable "subscription_id" {}

variable "client_id" {}

variable "client_secret" {}

variable "tenant_id" {}

#---------------
# Hub Providers
#---------------
variable "hub_subscription_id" {}

variable "hub_client_id" {}

variable "hub_client_secret" {}

#--------
# Locals
#--------
variable "helpers" {}

#----------------
# Resource Group
#----------------
variable "resource_group" {}

#-----------------
# Virtual Network
#-----------------
variable "virtual_network" {}

#---------------------------------------
# Hub <-> Spoke Virtual Network Peering
#---------------------------------------
variable "hub_spoke_peering" {}

#------------------------
# User Assigned Identity
#------------------------
variable "user_assigned_identity" {}

#-----------
# Key Vault
#-----------
variable "key_vault" {}

#------------------
# Key Vault Secret
#------------------
variable "key_vault_secret" {}

#-----------------
# Storage Account
#-----------------
variable "storage_account" {}

#-------------------
# Storage Container
#-------------------
variable "storage_container" {}

#--------------
# Service Plan
#--------------
variable "service_plan" {}

#----------------------
# Application Insights
#----------------------
variable "application_insights" {}

#---------------
# Linux Web App
#---------------
variable "linux_web_app" {}

#--------------------
# Linux Function App
#--------------------
variable "linux_function_app" {}

#------------------
# CosmosDB Account
#------------------
variable "cosmosdb_account" {}

#--------------
# MSSQL Server
#--------------
variable "mssql_server" {}

variable "admin_username" {}

variable "admin_password" {}

#----------------
# MSSQL Database
#----------------
variable "mssql_database" {}

#------------------------
# MSSQL Managed Instance
#------------------------
variable "mssql_managed_instance" {}

#------------------------
# MSSQL Managed Database
#------------------------
variable "mssql_managed_database" {}

#-------------------
# Private End Point
#-------------------
variable "private_endpoint" {}