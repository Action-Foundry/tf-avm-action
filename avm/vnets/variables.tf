# Variables for Virtual Networks AVM module

variable "vnets" {
  description = "Map of virtual networks to create"
  type = map(object({
    name                = string
    location            = optional(string)
    resource_group_name = string
    address_space       = list(string)
    subnets = optional(map(object({
      name             = string
      address_prefixes = list(string)
    })), {})
    tags = optional(map(string), {})
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
