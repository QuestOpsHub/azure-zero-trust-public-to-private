#---------------
# Random String
#---------------
output "random_string" {
  value = module.random_string
}

#----------------
# Resource Group
#---------------
output "resource_group" {
  value = module.resource_group
}

#-----------------
# Virtual Network
#-----------------
output "virtual_network" {
  value = module.virtual_network
}

#------------------
# Private Dns Zone
#------------------
output "private_dns_zone" {
  value = module.private_dns_zone
}

#------------------------
# User Assigned Identity
#------------------------
output "user_assigned_identity" {
  value = module.user_assigned_identity
}

#-----------
# Key Vault
#-----------
output "key_vault" {
  value = module.key_vault
}

#-----------
# Public IP
#-----------
output "public_ip" {
  value = module.public_ip
}

#--------------
# Bastion Host
#--------------
output "bastion_host" {
  value = module.bastion_host
}

#-----------------------
# Linux Virtual Machine
#-----------------------
output "linux_virtual_machine" {
  value = module.linux_virtual_machine
}