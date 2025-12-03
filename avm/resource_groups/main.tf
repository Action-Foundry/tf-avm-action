# Resource Groups using Azure Verified Module
# https://registry.terraform.io/modules/Azure/avm-res-resources-resourcegroup/azurerm/latest

module "resource_groups" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "~> 0.1"
  for_each = var.resource_groups

  name     = each.value.name
  location = coalesce(each.value.location, var.default_location)
  tags = merge(
    {
      environment = var.environment
      managed_by  = "terraform"
      module      = "avm-res-resources-resourcegroup"
    },
    each.value.tags
  )
}
