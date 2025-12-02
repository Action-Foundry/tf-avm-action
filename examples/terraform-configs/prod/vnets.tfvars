# Production Environment - Virtual Networks
# Azure Verified Modules Configuration

vnets = {
  # Primary application VNet with production-grade configuration
  app_vnet = {
    name                = "vnet-myapp-prod-eastus-001"
    location            = "eastus"
    resource_group_name = "rg-myapp-prod-eastus-001"
    address_space       = ["10.100.0.0/16"]
    
    subnets = {
      web = {
        name             = "snet-web-prod-001"
        address_prefixes = ["10.100.1.0/24"]
      }
      app = {
        name             = "snet-app-prod-001"
        address_prefixes = ["10.100.2.0/24"]
      }
      data = {
        name             = "snet-data-prod-001"
        address_prefixes = ["10.100.3.0/24"]
      }
      integration = {
        name             = "snet-integration-prod-001"
        address_prefixes = ["10.100.4.0/24"]
      }
    }
    
    tags = {
      cost_center = "engineering"
      owner       = "platform-team"
      project     = "myapp"
      backup      = "required"
      dr_tier     = "tier1"
    }
  }

  # Shared services VNet
  shared_vnet = {
    name                = "vnet-shared-prod-eastus-001"
    location            = "eastus"
    resource_group_name = "rg-shared-prod-eastus-001"
    address_space       = ["10.101.0.0/16"]
    
    subnets = {
      gateway = {
        name             = "GatewaySubnet"
        address_prefixes = ["10.101.0.0/27"]
      }
      bastion = {
        name             = "AzureBastionSubnet"
        address_prefixes = ["10.101.1.0/27"]
      }
      firewall = {
        name             = "AzureFirewallSubnet"
        address_prefixes = ["10.101.2.0/26"]
      }
      mgmt = {
        name             = "snet-mgmt-prod-001"
        address_prefixes = ["10.101.3.0/24"]
      }
    }
    
    tags = {
      cost_center = "infrastructure"
      owner       = "platform-team"
      project     = "shared-services"
      backup      = "required"
      dr_tier     = "tier2"
    }
  }
}
