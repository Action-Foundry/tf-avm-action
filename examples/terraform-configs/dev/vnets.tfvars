# Development Environment - Virtual Networks
# Azure Verified Modules Configuration

vnets = {
  # Primary application VNet
  app_vnet = {
    name                = "vnet-myapp-dev-eastus-001"
    location            = "eastus"
    resource_group_name = "rg-myapp-dev-eastus-001"
    address_space       = ["10.0.0.0/16"]
    
    subnets = {
      web = {
        name             = "snet-web-dev-001"
        address_prefixes = ["10.0.1.0/24"]
      }
      app = {
        name             = "snet-app-dev-001"
        address_prefixes = ["10.0.2.0/24"]
      }
      data = {
        name             = "snet-data-dev-001"
        address_prefixes = ["10.0.3.0/24"]
      }
    }
    
    tags = {
      cost_center = "engineering"
      owner       = "platform-team"
      project     = "myapp"
    }
  }

  # Shared services VNet
  shared_vnet = {
    name                = "vnet-shared-dev-eastus-001"
    location            = "eastus"
    resource_group_name = "rg-shared-dev-eastus-001"
    address_space       = ["10.1.0.0/16"]
    
    subnets = {
      gateway = {
        name             = "GatewaySubnet"  # Azure requires this specific name
        address_prefixes = ["10.1.0.0/27"]
      }
      bastion = {
        name             = "AzureBastionSubnet"  # Azure requires this specific name
        address_prefixes = ["10.1.1.0/27"]
      }
      mgmt = {
        name             = "snet-mgmt-dev-001"
        address_prefixes = ["10.1.2.0/24"]
      }
    }
    
    tags = {
      cost_center = "infrastructure"
      owner       = "platform-team"
      project     = "shared-services"
    }
  }
}
