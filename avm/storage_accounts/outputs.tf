# Outputs for Storage Accounts AVM module

output "storage_account_ids" {
  description = "Map of storage account IDs"
  value = {
    for k, sa in module.storage_accounts : k => try(sa.resource_id, sa.id)
  }
}

output "storage_account_names" {
  description = "Map of storage account names"
  value = {
    for k, sa in module.storage_accounts : k => sa.name
  }
}
