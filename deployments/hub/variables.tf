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

#------------------
# Private Dns Zone
#------------------
variable "private_dns_zone" {}

#------------------------
# User Assigned Identity
#------------------------
variable "user_assigned_identity" {}

#------------------------
# Network Security Group    
#------------------------
variable "network_security_group" {}

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