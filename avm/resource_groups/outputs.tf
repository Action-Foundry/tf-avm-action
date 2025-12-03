# Outputs for Resource Groups AVM module

output "resource_group_ids" {
  description = "Map of resource group IDs"
  value = {
    for k, rg in module.resource_groups : k => try(rg.resource_id, rg.id)
  }
}

output "resource_group_names" {
  description = "Map of resource group names"
  value = {
    for k, rg in module.resource_groups : k => rg.name
  }
}
