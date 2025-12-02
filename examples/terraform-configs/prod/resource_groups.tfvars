# Production Environment - Resource Groups
# Azure Verified Modules Configuration

resource_groups = {
  # Primary resource group for application resources
  app_rg = {
    name     = "rg-myapp-prod-eastus-001"
    location = "eastus"
    tags = {
      cost_center = "engineering"
      owner       = "platform-team"
      project     = "myapp"
      backup      = "required"
      dr_tier     = "tier1"
    }
  }

  # Resource group for data resources
  data_rg = {
    name     = "rg-data-prod-eastus-001"
    location = "eastus"
    tags = {
      cost_center = "data"
      owner       = "data-team"
      project     = "myapp"
      backup      = "required"
      dr_tier     = "tier1"
    }
  }

  # Resource group for shared/common resources
  shared_rg = {
    name     = "rg-shared-prod-eastus-001"
    location = "eastus"
    tags = {
      cost_center = "infrastructure"
      owner       = "platform-team"
      project     = "shared-services"
      backup      = "required"
      dr_tier     = "tier2"
    }
  }
}
