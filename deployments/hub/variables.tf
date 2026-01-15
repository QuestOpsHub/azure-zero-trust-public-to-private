#--------------------
# Required Providers
#--------------------
variable "subscription_id" {}

variable "client_id" {}

variable "client_secret" {}

variable "tenant_id" {}

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

#------------------------
# Network Security Group    
#------------------------
variable "network_security_group" {}

#------------------
# Private Dns Zone
#------------------
variable "private_dns_zone" {}

#------------------------
# User Assigned Identity
#------------------------
variable "user_assigned_identity" {}

#----------------------
# Application Insights
#----------------------
variable "application_insights" {}

#----------------
# API Management
#----------------
variable "api_management" {}

#-----------
# Key Vault
#-----------
variable "key_vault" {}

#------------------
# Key Vault Secret
#------------------
variable "key_vault_secret" {}

#-----------
# Public IP
#-----------
variable "public_ip" {}

#--------------
# Bastion Host
#--------------
variable "bastion_host" {}

#-----------------------
# Linux Virtual Machine
#-----------------------
variable "linux_virtual_machine" {}

variable "admin_username" {}

variable "admin_password" {}

#-------------------------
# Windows Virtual Machine
#-------------------------
variable "windows_virtual_machine" {}

#--------------------
# Container Registry
#--------------------
variable "container_registry" {}