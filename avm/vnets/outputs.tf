# Outputs for Virtual Networks AVM module

output "vnet_ids" {
  description = "Map of virtual network IDs"
  value = {
    for k, vnet in module.vnets : k => try(vnet.resource_id, vnet.id)
  }
}

output "vnet_names" {
  description = "Map of virtual network names"
  value = {
    for k, vnet in module.vnets : k => vnet.name
  }
}
