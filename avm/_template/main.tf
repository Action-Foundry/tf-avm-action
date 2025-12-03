# [MODULE_DISPLAY_NAME] using Azure Verified Module
# https://registry.terraform.io/modules/[MODULE_SOURCE]/latest

module "[MODULE_VAR_NAME]" {
  source   = "[MODULE_SOURCE]"
  version  = "~> 0.1"
  for_each = var.[MODULE_VAR_NAME]

  # Core parameters - most AVM modules follow this pattern
  name     = each.value.name
  location = try(each.value.location, var.default_location)
  
  # Conditionally set resource_group_name if provided
  # Most resources need this, some (like resource groups) don't
  resource_group_name = each.value.resource_group_name

  # Note: This generic template provides a baseline configuration
  # Module-specific parameters should be added to the tfvars file
  # and passed through the module block. Refer to the AVM module documentation.

  tags = merge(
    {
      environment = var.environment
      managed_by  = "terraform"
      module      = "[MODULE_SOURCE_SHORT]"
    },
    each.value.tags
  )
}
