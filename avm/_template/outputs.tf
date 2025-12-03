# Outputs for [MODULE_DISPLAY_NAME] AVM module

output "[MODULE_VAR_NAME]_ids" {
  description = "Map of [MODULE_DISPLAY_NAME] resource IDs"
  value = {
    for k, resource in module.[MODULE_VAR_NAME] : k => try(resource.resource_id, resource.id, null)
  }
}

output "[MODULE_VAR_NAME]_names" {
  description = "Map of [MODULE_DISPLAY_NAME] resource names"
  value = {
    for k, resource in module.[MODULE_VAR_NAME] : k => try(resource.name, resource.resource_name, k)
  }
}
