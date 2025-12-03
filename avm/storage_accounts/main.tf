# Storage Accounts using Azure Verified Module
# https://registry.terraform.io/modules/Azure/avm-res-storage-storageaccount/azurerm/latest

module "storage_accounts" {
  source   = "Azure/avm-res-storage-storageaccount/azurerm"
  version  = "~> 0.1"
  for_each = var.storage_accounts

  name                     = each.value.name
  location                 = coalesce(each.value.location, var.default_location)
  resource_group_name      = each.value.resource_group_name
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type
  account_kind             = each.value.account_kind

  tags = merge(
    {
      environment = var.environment
      managed_by  = "terraform"
      module      = "avm-res-storage-storageaccount"
    },
    each.value.tags
  )
}
