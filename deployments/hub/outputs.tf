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

#---------------
# User Identity
#---------------
output "user_assigned_identity" {
  value = module.user_assigned_identity
}