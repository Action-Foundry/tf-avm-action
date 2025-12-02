# Development Environment - Resource Groups
# Azure Verified Modules Configuration

resource_groups = {
  # Primary resource group for application resources
  app_rg = {
    name     = "rg-myapp-dev-eastus-001"
    location = "eastus"
    tags = {
      cost_center = "engineering"
      owner       = "platform-team"
      project     = "myapp"
    }
  }

  # Resource group for data resources
  data_rg = {
    name     = "rg-data-dev-eastus-001"
    location = "eastus"
    tags = {
      cost_center = "data"
      owner       = "data-team"
      project     = "myapp"
    }
  }

  # Resource group for shared/common resources
  shared_rg = {
    name     = "rg-shared-dev-eastus-001"
    location = "eastus"
    tags = {
      cost_center = "infrastructure"
      owner       = "platform-team"
      project     = "shared-services"
    }
  }
}
