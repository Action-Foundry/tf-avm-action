# Development Environment - Storage Accounts
# Azure Verified Modules Configuration

storage_accounts = {
  # Application storage account
  app_storage = {
    name                     = "stmyappdeveastus001"  # Must be globally unique
    location                 = "eastus"
    resource_group_name      = "rg-myapp-dev-eastus-001"
    account_tier             = "Standard"
    account_replication_type = "LRS"  # Locally redundant storage (sufficient for dev)
    account_kind             = "StorageV2"
    tags = {
      cost_center         = "engineering"
      owner               = "platform-team"
      project             = "myapp"
      data_classification = "internal"
    }
  }

  # Data lake storage account
  data_storage = {
    name                     = "stdatadeveastus001"  # Must be globally unique
    location                 = "eastus"
    resource_group_name      = "rg-data-dev-eastus-001"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    account_kind             = "StorageV2"
    tags = {
      cost_center         = "data"
      owner               = "data-team"
      project             = "myapp"
      data_classification = "confidential"
    }
  }

  # Diagnostics and logs storage
  logs_storage = {
    name                     = "stlogsdeveastus001"  # Must be globally unique
    location                 = "eastus"
    resource_group_name      = "rg-shared-dev-eastus-001"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    account_kind             = "StorageV2"
    tags = {
      cost_center         = "infrastructure"
      owner               = "platform-team"
      project             = "shared-services"
      data_classification = "internal"
    }
  }
}
