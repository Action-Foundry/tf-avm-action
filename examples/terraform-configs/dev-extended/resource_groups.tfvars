# Resource Groups Configuration
# Basic building block for organizing Azure resources

resource_groups = {
  rg1 = {
    name     = "rg-myapp-dev-eastus-001"
    location = "eastus"
    tags = {
      cost_center = "engineering"
      owner       = "platform-team"
    }
  }
}
