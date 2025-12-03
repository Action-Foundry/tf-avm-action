# Variables for Storage Accounts AVM module

variable "storage_accounts" {
  description = "Map of storage accounts to create"
  type = map(object({
    name                     = string
    location                 = optional(string)
    resource_group_name      = string
    account_tier             = optional(string, "Standard")
    account_replication_type = optional(string, "LRS")
    account_kind             = optional(string, "StorageV2")
    tags                     = optional(map(string), {})
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
