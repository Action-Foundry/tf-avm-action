# Application Insights Configuration
# This example shows how to deploy Application Insights using AVM modules

insights_component = {
  appi1 = {
    name                = "appi-myapp-dev-eastus-001"
    location            = "eastus"
    resource_group_name = "rg-myapp-dev-eastus-001"
    tags = {
      cost_center = "engineering"
      owner       = "platform-team"
      environment = "dev"
      monitoring  = "enabled"
    }
  }
}
