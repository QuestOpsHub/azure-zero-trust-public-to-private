#----------------
# Resource Group
#----------------
output "resource_group" {
  value = module.resource_group
}

#-----------------
# Virtual Network
#-----------------
output "virtual_network" {
  value = module.virtual_network
}

#------------------------
# Network Security Group    
#------------------------
output "network_security_group" {
  value = module.network_security_group
}

#------------------
# Private DNS Zone
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

#------------------
# Key Vault Secret
#------------------
output "key_vault_secret" {
  value = module.key_vault_secret
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

#-------------------------
# Windows Virtual Machine
#-------------------------
output "windows_virtual_machine" {
  value = module.windows_virtual_machine
}

#--------------------
# Container Registry
#--------------------
output "container_registry" {
  value     = module.container_registry
  sensitive = true
}