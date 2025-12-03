# Virtual Networks (VNets) AVM Module

This module provides a self-contained Terraform configuration for deploying Azure Virtual Networks using the [Azure Verified Module for Virtual Networks](https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm).

## Overview

This module wraps the official AVM module for Virtual Networks and provides:
- CAF-compliant naming and tagging
- Support for multiple VNets in a single deployment
- Built-in subnet configuration
- Environment-based configuration
- Default location configuration with per-resource override capability

## Usage

This module is designed to be used by the `avm-deploy.sh` script but can also be used independently.

### Independent Usage

```hcl
module "vnets" {
  source = "./avm/vnets"
  
  environment      = "dev"
  default_location = "eastus"
  
  vnets = {
    vnet1 = {
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
      }
      
      tags = {
        cost_center = "engineering"
      }
    }
  }
}
```

### With tfvars File

Create a `vnets.tfvars` file:

```hcl
vnets = {
  vnet1 = {
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
    }
  }
}
```

Then use:

```bash
terraform init
terraform plan -var-file=vnets.tfvars -var="environment=dev" -var="default_location=eastus"
terraform apply -var-file=vnets.tfvars -var="environment=dev" -var="default_location=eastus"
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vnets | Map of virtual networks to create | `map(object)` | `{}` | no |
| default_location | Default location for resources if not specified | `string` | n/a | yes |
| environment | Environment name (dev, test, uat, staging, prod) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| vnet_ids | Map of virtual network IDs |
| vnet_names | Map of virtual network names |

## VNet Object Structure

Each VNet in the `vnets` map should have:

```hcl
{
  name                = string                 # VNet name (required)
  location            = optional(string)       # Azure region (optional, uses default_location if not set)
  resource_group_name = string                 # Resource group name where VNet will be created (required)
  address_space       = list(string)           # CIDR blocks for VNet (required)
  subnets = optional(map(object({              # Subnets configuration (optional)
    name             = string
    address_prefixes = list(string)
  })))
  tags = optional(map(string))                 # Additional tags (optional)
}
```

## CAF Naming Convention

Follow Azure Cloud Adoption Framework naming conventions:

**VNet:**
```
vnet-<workload>-<environment>-<region>-<instance>
Example: vnet-myapp-dev-eastus-001
```

**Subnet:**
```
snet-<purpose>-<environment>-<instance>
Examples: snet-web-dev-001, snet-app-dev-001
```

## Tags

Standard tags automatically applied by this module:
- `environment`: Set from the environment variable
- `managed_by`: Always set to "terraform"
- `module`: Always set to "avm-res-network-virtualnetwork"

Additional tags can be provided via the `tags` attribute in each VNet definition.

## Subnet Configuration

Subnets are defined as a map within each VNet configuration. The key is a logical identifier (used internally), and the value contains:
- `name`: The actual subnet name in Azure
- `address_prefixes`: CIDR blocks for the subnet

Example:
```hcl
subnets = {
  web = {
    name             = "snet-web-dev-001"
    address_prefixes = ["10.0.1.0/24"]
  }
  app = {
    name             = "snet-app-dev-001"
    address_prefixes = ["10.0.2.0/24"]
  }
}
```

## Requirements

- Terraform >= 1.5.0
- Azure Provider ~> 3.0
- Azure Verified Module: Azure/avm-res-network-virtualnetwork/azurerm ~> 0.1

## Dependencies

Resource groups referenced in `resource_group_name` must exist before deploying VNets.

## References

- [AVM Virtual Network Module](https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm)
- [Azure CAF Naming Best Practices](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
