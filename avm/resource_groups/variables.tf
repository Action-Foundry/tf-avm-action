# Variables for Resource Groups AVM module

variable "resource_groups" {
  description = "Map of resource groups to create"
  type = map(object({
    name     = string
    location = optional(string)
    tags     = optional(map(string), {})
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
