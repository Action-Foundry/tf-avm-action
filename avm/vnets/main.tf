# Virtual Networks using Azure Verified Module
# https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest

module "vnets" {
  source   = "Azure/avm-res-network-virtualnetwork/azurerm"
  version  = "~> 0.1"
  for_each = var.vnets

  name                = each.value.name
  location            = coalesce(each.value.location, var.default_location)
  resource_group_name = each.value.resource_group_name
  address_space       = each.value.address_space

  subnets = {
    for subnet_key, subnet in each.value.subnets : subnet_key => {
      name             = subnet.name
      address_prefixes = subnet.address_prefixes
    }
  }

  tags = merge(
    {
      environment = var.environment
      managed_by  = "terraform"
      module      = "avm-res-network-virtualnetwork"
    },
    each.value.tags
  )
}
