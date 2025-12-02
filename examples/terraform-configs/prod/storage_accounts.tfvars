# Production Environment - Storage Accounts
# Azure Verified Modules Configuration
# Production uses higher redundancy (GRS/RAGRS) for data protection

storage_accounts = {
  # Application storage account with geo-redundancy
  app_storage = {
    name                     = "stmyappprodeastus001"  # Must be globally unique
    location                 = "eastus"
    resource_group_name      = "rg-myapp-prod-eastus-001"
    account_tier             = "Standard"
    account_replication_type = "GRS"  # Geo-redundant storage for production
    account_kind             = "StorageV2"
    tags = {
      cost_center         = "engineering"
      owner               = "platform-team"
      project             = "myapp"
      data_classification = "internal"
      backup              = "required"
      dr_tier             = "tier1"
    }
  }

  # Data lake storage account with read-access geo-redundancy
  data_storage = {
    name                     = "stdataprodeastus001"  # Must be globally unique
    location                 = "eastus"
    resource_group_name      = "rg-data-prod-eastus-001"
    account_tier             = "Standard"
    account_replication_type = "RAGRS"  # Read-access geo-redundant storage
    account_kind             = "StorageV2"
    tags = {
      cost_center         = "data"
      owner               = "data-team"
      project             = "myapp"
      data_classification = "confidential"
      backup              = "required"
      dr_tier             = "tier1"
    }
  }

  # Diagnostics and logs storage with geo-redundancy
  logs_storage = {
    name                     = "stlogsprodeastus001"  # Must be globally unique
    location                 = "eastus"
    resource_group_name      = "rg-shared-prod-eastus-001"
    account_tier             = "Standard"
    account_replication_type = "GRS"
    account_kind             = "StorageV2"
    tags = {
      cost_center         = "infrastructure"
      owner               = "platform-team"
      project             = "shared-services"
      data_classification = "internal"
      backup              = "required"
      dr_tier             = "tier2"
    }
  }
}
