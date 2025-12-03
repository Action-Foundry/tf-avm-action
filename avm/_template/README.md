# [MODULE_DISPLAY_NAME] AVM Module

This module provides a self-contained Terraform configuration for deploying [MODULE_DISPLAY_NAME] using the [Azure Verified Module for [MODULE_DISPLAY_NAME]](https://registry.terraform.io/modules/[MODULE_SOURCE]).

## Overview

This module wraps the official AVM module for [MODULE_DISPLAY_NAME] and provides:
- CAF-compliant naming and tagging
- Support for multiple resources in a single deployment
- Environment-based configuration
- Default location configuration with per-resource override capability

## Usage

This module is designed to be used by the `avm-deploy.sh` script but can also be used independently.

### Independent Usage

```hcl
module "[MODULE_VAR_NAME]" {
  source = "./avm/[MODULE_VAR_NAME]"
  
  environment      = "dev"
  default_location = "eastus"
  
  [MODULE_VAR_NAME] = {
    resource1 = {
      name                = "[RESOURCE_NAME_EXAMPLE]"
      location            = "eastus"
      resource_group_name = "rg-myapp-dev-eastus-001"
      tags = {
        cost_center = "engineering"
        owner       = "platform-team"
      }
      # Additional module-specific properties can be added here
      # Refer to the AVM module documentation for available options
    }
  }
}
```

### With tfvars File

Create a `[MODULE_VAR_NAME].tfvars` file:

```hcl
[MODULE_VAR_NAME] = {
  resource1 = {
    name                = "[RESOURCE_NAME_EXAMPLE]"
    location            = "eastus"
    resource_group_name = "rg-myapp-dev-eastus-001"
    tags = {
      cost_center = "engineering"
    }
  }
}
```

Then use:

```bash
terraform init
terraform plan -var-file=[MODULE_VAR_NAME].tfvars -var="environment=dev" -var="default_location=eastus"
terraform apply -var-file=[MODULE_VAR_NAME].tfvars -var="environment=dev" -var="default_location=eastus"
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| [MODULE_VAR_NAME] | Map of [MODULE_DISPLAY_NAME] resources to create | `map(object)` | `{}` | no |
| default_location | Default location for resources if not specified | `string` | n/a | yes |
| environment | Environment name (dev, test, uat, staging, prod) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| [MODULE_VAR_NAME]_ids | Map of resource IDs |
| [MODULE_VAR_NAME]_names | Map of resource names |

## Resource Object Structure

Each resource in the `[MODULE_VAR_NAME]` map should have:

```hcl
{
  name                = string                 # Resource name (required)
  location            = optional(string)       # Azure region (optional, uses default_location if not set)
  resource_group_name = string                 # Resource group name (required for most resources)
  tags                = optional(map(string))  # Additional tags (optional)
  # Additional module-specific properties based on the AVM module documentation
}
```

## CAF Naming Convention

Follow Azure Cloud Adoption Framework naming conventions. See the [Azure CAF Naming Best Practices](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging) for resource type-specific naming patterns.

## Tags

Standard tags automatically applied by this module:
- `environment`: Set from the environment variable
- `managed_by`: Always set to "terraform"
- `module`: The AVM module name

Additional tags can be provided via the `tags` attribute in each resource definition.

## Requirements

- Terraform >= 1.5.0
- Azure Provider ~> 3.0
- Azure Verified Module: [MODULE_SOURCE] ~> 0.1

## Dependencies

Resource groups referenced in `resource_group_name` must exist before deploying resources (unless the module creates resource groups).

## References

- [AVM Module Documentation](https://registry.terraform.io/modules/[MODULE_SOURCE])
- [Azure CAF Naming Best Practices](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
