# Resource Groups AVM Module

This module provides a self-contained Terraform configuration for deploying Azure Resource Groups using the [Azure Verified Module for Resource Groups](https://registry.terraform.io/modules/Azure/avm-res-resources-resourcegroup/azurerm).

## Overview

This module wraps the official AVM module for Resource Groups and provides:
- CAF-compliant naming and tagging
- Support for multiple resource groups in a single deployment
- Environment-based configuration
- Default location configuration with per-resource override capability

## Usage

This module is designed to be used by the `avm-deploy.sh` script but can also be used independently.

### Independent Usage

```hcl
module "resource_groups" {
  source = "./avm/resource_groups"
  
  environment      = "dev"
  default_location = "eastus"
  
  resource_groups = {
    rg1 = {
      name     = "rg-myapp-dev-eastus-001"
      location = "eastus"
      tags = {
        cost_center = "engineering"
        owner       = "platform-team"
      }
    }
    rg2 = {
      name     = "rg-data-dev-eastus-001"
      # Uses default_location if not specified
      tags = {
        cost_center = "data"
      }
    }
  }
}
```

### With tfvars File

Create a `resource_groups.tfvars` file:

```hcl
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
```

Then use:

```bash
terraform init
terraform plan -var-file=resource_groups.tfvars -var="environment=dev" -var="default_location=eastus"
terraform apply -var-file=resource_groups.tfvars -var="environment=dev" -var="default_location=eastus"
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_groups | Map of resource groups to create | `map(object)` | `{}` | no |
| default_location | Default location for resources if not specified | `string` | n/a | yes |
| environment | Environment name (dev, test, uat, staging, prod) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| resource_group_ids | Map of resource group IDs |
| resource_group_names | Map of resource group names |

## Resource Group Object Structure

Each resource group in the `resource_groups` map should have:

```hcl
{
  name     = string           # Azure resource group name (required)
  location = optional(string) # Azure region (optional, uses default_location if not set)
  tags     = optional(map)    # Additional tags (optional)
}
```

## CAF Naming Convention

Follow Azure Cloud Adoption Framework naming conventions:

```
rg-<workload>-<environment>-<region>-<instance>
Example: rg-myapp-dev-eastus-001
```

## Tags

Standard tags automatically applied by this module:
- `environment`: Set from the environment variable
- `managed_by`: Always set to "terraform"
- `module`: Always set to "avm-res-resources-resourcegroup"

Additional tags can be provided via the `tags` attribute in each resource group definition.

## Requirements

- Terraform >= 1.5.0
- Azure Provider ~> 3.0
- Azure Verified Module: Azure/avm-res-resources-resourcegroup/azurerm ~> 0.1

## References

- [AVM Resource Groups Module](https://registry.terraform.io/modules/Azure/avm-res-resources-resourcegroup/azurerm)
- [Azure CAF Naming Best Practices](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
