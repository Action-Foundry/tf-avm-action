# Variables for [MODULE_DISPLAY_NAME] AVM module

variable "[MODULE_VAR_NAME]" {
  description = "Map of [MODULE_DISPLAY_NAME] resources to create"
  type = map(object({
    name                = string
    location            = optional(string)
    resource_group_name = optional(string)
    tags                = optional(map(string), {})
    # Additional properties can be specified based on the module's input variables
    # Users should refer to the module documentation for available options
    # Note: This generic template uses common AVM module parameters (name, location, resource_group_name)
    # For modules with different parameter requirements, customize this file
  }))
  default = {}
}

variable "default_location" {
  description = "Default location for resources if not specified"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, test, uat, staging, prod)"
  type        = string
}
