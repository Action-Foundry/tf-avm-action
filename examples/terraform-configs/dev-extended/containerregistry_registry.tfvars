# Azure Container Registry Configuration
# This example shows how to deploy Azure Container Registry using AVM modules

containerregistry_registry = {
  acr1 = {
    name                = "acrmyappdeveastus001"  # Must be globally unique, alphanumeric only
    location            = "eastus"
    resource_group_name = "rg-myapp-dev-eastus-001"
    tags = {
      cost_center = "engineering"
      owner       = "platform-team"
      environment = "dev"
    }
  }
}
