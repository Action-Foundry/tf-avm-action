# Azure Verified Modules (AVM) Support

This document provides comprehensive guidance on using Azure Verified Modules (AVM) with the tf-avm-action to deploy Azure resources following Cloud Adoption Framework (CAF) standards and Azure best practices.

## Table of Contents

- [Overview](#overview)
- [What are Azure Verified Modules?](#what-are-azure-verified-modules)
- [Quick Start](#quick-start)
- [Directory Structure](#directory-structure)
- [Supported Resource Types](#supported-resource-types)
- [Usage Examples](#usage-examples)
- [Azure CAF Best Practices](#azure-caf-best-practices)
- [Advanced Configuration](#advanced-configuration)
- [Troubleshooting](#troubleshooting)

## Overview

The AVM mode in tf-avm-action enables streamlined deployment of Azure resources across multiple environments using:

- **Azure Verified Modules (AVM)**: Pre-validated, enterprise-ready Terraform modules from Microsoft
- **Environment-based deployment**: Support for dev, test, uat, staging, and prod environments
- **tfvars-driven configuration**: Simple, declarative configuration using `.tfvars` files
- **CAF compliance**: Built-in support for Azure Cloud Adoption Framework naming and tagging standards
- **DRY principles**: Reusable configurations across environments

## What are Azure Verified Modules?

Azure Verified Modules (AVM) are officially supported Terraform modules maintained by Microsoft and the community. They provide:

- ✅ **Best Practice Implementations**: Follow Azure's recommended patterns
- ✅ **Security Hardened**: Implement security defaults and best practices
- ✅ **Well Documented**: Comprehensive documentation and examples
- ✅ **Production Ready**: Tested and validated for enterprise use
- ✅ **Actively Maintained**: Regular updates and improvements

Learn more: [https://azure.github.io/Azure-Verified-Modules/](https://azure.github.io/Azure-Verified-Modules/)

## Quick Start

### 1. Create Directory Structure

```bash
# In your repository root
mkdir -p terraform/dev
mkdir -p terraform/prod
```

### 2. Create tfvars Files

**terraform/dev/resource_groups.tfvars**:
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

**terraform/dev/vnets.tfvars**:
```hcl
vnets = {
  vnet1 = {
    name                = "vnet-myapp-dev-eastus-001"
    location            = "eastus"
    resource_group_name = "rg-myapp-dev-eastus-001"
    address_space       = ["10.0.0.0/16"]
    subnets = {
      subnet1 = {
        name             = "snet-web-dev-001"
        address_prefixes = ["10.0.1.0/24"]
      }
      subnet2 = {
        name             = "snet-app-dev-001"
        address_prefixes = ["10.0.2.0/24"]
      }
    }
    tags = {
      cost_center = "engineering"
    }
  }
}
```

### 3. Configure Workflow

**.github/workflows/deploy-avm.yml**:
```yaml
name: Deploy Azure Resources with AVM

on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        type: choice
        options:
          - dev
          - prod

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Azure Login
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      
      - name: Deploy with AVM
        uses: Action-Foundry/tf-avm-action@v1
        with:
          # Enable AVM mode
          enable_avm_mode: 'true'
          
          # Specify environments (comma-separated for multiple)
          avm_environments: 'dev'
          
          # Resource types to deploy
          avm_resource_types: 'resource_groups,vnets,storage_accounts'
          
          # Default Azure location
          avm_location: 'eastus'
          
          # Terraform working directory
          terraform_working_dir: './terraform'
          
          # Azure authentication
          azure_client_id: ${{ secrets.AZURE_CLIENT_ID }}
          azure_tenant_id: ${{ secrets.AZURE_TENANT_ID }}
          azure_subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          azure_use_oidc: 'true'
```

## Directory Structure

The recommended directory structure follows Azure CAF best practices:

```
repository/
├── .github/
│   └── workflows/
│       └── deploy-avm.yml          # Deployment workflow
├── terraform/                       # Terraform working directory
│   ├── dev/                        # Development environment
│   │   ├── resource_groups.tfvars  # Resource group definitions
│   │   ├── vnets.tfvars           # Virtual network definitions
│   │   └── storage_accounts.tfvars # Storage account definitions
│   ├── test/                       # Test environment
│   │   ├── resource_groups.tfvars
│   │   └── vnets.tfvars
│   ├── uat/                        # UAT environment
│   │   └── resource_groups.tfvars
│   ├── staging/                    # Staging environment
│   │   └── resource_groups.tfvars
│   └── prod/                       # Production environment
│       ├── resource_groups.tfvars
│       ├── vnets.tfvars
│       └── storage_accounts.tfvars
└── README.md
```

### Key Points:

- Each environment has its own folder under `terraform/`
- Environment folders contain `.tfvars` files for each resource type
- Standard environment names: `dev`, `test`, `uat`, `staging`, `prod`
- Only deploy resource types that have corresponding `.tfvars` files

## Supported Resource Types

### Resource Groups

**Module**: `Azure/avm-res-resources-resourcegroup/azurerm`

**tfvars Format** (`resource_groups.tfvars`):
```hcl
resource_groups = {
  # Key is a logical identifier (used internally)
  rg1 = {
    name     = "rg-myapp-dev-eastus-001"  # Actual Azure resource name
    location = "eastus"                    # Azure region
    tags = {
      cost_center = "engineering"
      owner       = "platform-team"
    }
  }
  
  rg2 = {
    name     = "rg-data-dev-eastus-001"
    location = "eastus"
    tags = {
      cost_center = "data"
    }
  }
}
```

**Naming Convention** (CAF-compliant):
```
rg-<app-or-service>-<environment>-<region>-<instance>
Example: rg-myapp-dev-eastus-001
```

### Virtual Networks (VNets)

**Module**: `Azure/avm-res-network-virtualnetwork/azurerm`

**tfvars Format** (`vnets.tfvars`):
```hcl
vnets = {
  vnet1 = {
    name                = "vnet-myapp-dev-eastus-001"
    location            = "eastus"
    resource_group_name = "rg-myapp-dev-eastus-001"  # Must exist
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

**Naming Convention** (CAF-compliant):
```
VNet:   vnet-<app-or-service>-<environment>-<region>-<instance>
Subnet: snet-<purpose>-<environment>-<instance>

Examples:
  vnet-myapp-dev-eastus-001
  snet-web-dev-001
```

### Storage Accounts

**Module**: `Azure/avm-res-storage-storageaccount/azurerm`

**tfvars Format** (`storage_accounts.tfvars`):
```hcl
storage_accounts = {
  sa1 = {
    name                     = "stmyappdeveastus001"  # Must be globally unique, 3-24 chars, lowercase, no hyphens
    location                 = "eastus"
    resource_group_name      = "rg-myapp-dev-eastus-001"
    account_tier             = "Standard"              # Standard or Premium
    account_replication_type = "LRS"                   # LRS, GRS, RAGRS, ZRS
    account_kind             = "StorageV2"             # StorageV2 (recommended), BlobStorage, FileStorage
    tags = {
      cost_center = "engineering"
      data_classification = "internal"
    }
  }
}
```

**Naming Convention** (CAF-compliant):
```
st<app-or-service><environment><region><instance>
Example: stmyappdeveastus001

Note: Storage account names must be:
- Globally unique across all of Azure
- 3-24 characters
- Lowercase letters and numbers only
- No hyphens or special characters
```

## Usage Examples

### Single Environment Deployment

Deploy only the development environment:

```yaml
- name: Deploy Dev Environment
  uses: Action-Foundry/tf-avm-action@v1
  with:
    enable_avm_mode: 'true'
    avm_environments: 'dev'
    avm_resource_types: 'resource_groups,vnets,storage_accounts'
    terraform_working_dir: './terraform'
    azure_use_oidc: 'true'
```

### Multi-Environment Deployment

Deploy multiple environments in sequence:

```yaml
- name: Deploy Multiple Environments
  uses: Action-Foundry/tf-avm-action@v1
  with:
    enable_avm_mode: 'true'
    avm_environments: 'dev,test,prod'  # Comma-separated
    avm_resource_types: 'resource_groups,vnets'
    terraform_working_dir: './terraform'
    azure_use_oidc: 'true'
```

### Selective Resource Deployment

Deploy only specific resource types:

```yaml
- name: Deploy Only Resource Groups
  uses: Action-Foundry/tf-avm-action@v1
  with:
    enable_avm_mode: 'true'
    avm_environments: 'dev'
    avm_resource_types: 'resource_groups'  # Only RGs
    terraform_working_dir: './terraform'
```

### Custom Azure Location

Override the default location:

```yaml
- name: Deploy to West Europe
  uses: Action-Foundry/tf-avm-action@v1
  with:
    enable_avm_mode: 'true'
    avm_environments: 'prod'
    avm_location: 'westeurope'  # Default location
    terraform_working_dir: './terraform'
```

### With Backend Configuration

Use Azure Storage for state:

```yaml
- name: Deploy with Remote State
  uses: Action-Foundry/tf-avm-action@v1
  with:
    enable_avm_mode: 'true'
    avm_environments: 'prod'
    terraform_working_dir: './terraform'
    terraform_backend_config: |
      storage_account_name=mytfstate
      container_name=tfstate
      resource_group_name=rg-tfstate-prod
    azure_use_oidc: 'true'
```

### Matrix Strategy for Multiple Environments

Deploy environments in parallel:

```yaml
jobs:
  deploy:
    strategy:
      matrix:
        environment: [dev, test, prod]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      
      - name: Deploy ${{ matrix.environment }}
        uses: Action-Foundry/tf-avm-action@v1
        with:
          enable_avm_mode: 'true'
          avm_environments: ${{ matrix.environment }}
          terraform_working_dir: './terraform'
          azure_use_oidc: 'true'
```

## Azure CAF Best Practices

### Naming Conventions

The action supports and encourages Azure Cloud Adoption Framework naming conventions:

| Resource Type | Format | Example |
|--------------|--------|---------|
| Resource Group | `rg-<workload>-<env>-<region>-<###>` | `rg-myapp-dev-eastus-001` |
| Virtual Network | `vnet-<workload>-<env>-<region>-<###>` | `vnet-myapp-dev-eastus-001` |
| Subnet | `snet-<purpose>-<env>-<###>` | `snet-web-dev-001` |
| Storage Account | `st<workload><env><region><###>` | `stmyappdeveastus001` |

**References**:
- [Azure Naming Convention Best Practices](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
- [Resource Naming Examples](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)

### Tagging Strategy

Standard tags are automatically applied by the action:

```hcl
tags = {
  environment = "<env>"           # Automatically set (dev, test, prod, etc.)
  managed_by  = "terraform"       # Automatically set
  module      = "<avm-module>"    # Automatically set
}
```

Recommended additional tags to include in your tfvars:

```hcl
tags = {
  cost_center         = "engineering"
  owner               = "platform-team"
  project             = "myapp"
  data_classification = "internal"  # For storage accounts
  backup              = "required"  # For production resources
  dr_tier             = "mission-critical"  # For critical resources
}
```

**Reference**: [Azure Tagging Strategy](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging)

### Environment Strategy

Recommended environment naming and purpose:

| Environment | Purpose | Typical Configuration |
|-------------|---------|---------------------|
| `dev` | Development | Lower SKUs, minimal redundancy |
| `test` | Testing/QA | Similar to dev, isolated |
| `uat` | User Acceptance Testing | Production-like config |
| `staging` | Pre-production | Identical to production |
| `prod` | Production | High availability, redundancy |

### Security Best Practices

1. **Use OIDC Authentication** (no secrets in workflows):
   ```yaml
   permissions:
     id-token: write
   
   - uses: azure/login@v2
     with:
       client-id: ${{ secrets.AZURE_CLIENT_ID }}
       tenant-id: ${{ secrets.AZURE_TENANT_ID }}
       subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
   ```

2. **Store State Remotely**:
   ```yaml
   terraform_backend_config: |
     storage_account_name=mytfstate
     container_name=tfstate
   ```

3. **Use Environment Protection Rules**:
   - Require approvals for production deployments
   - Limit who can deploy to production
   - Use GitHub Environments feature

4. **Review Plans Before Apply**:
   - In CI/CD, review Terraform plans
   - Use PR workflows for plan reviews

## Advanced Configuration

### Custom Module Versions

By default, the action uses the latest compatible version (`~> 0.1`) of each AVM module. This ensures you get updates while maintaining compatibility.

The module versions are defined in the generated Terraform configuration and follow semantic versioning:
- `~> 0.1`: Allows patch and minor updates (0.1.x)
- `~> 1.0`: Allows patch and minor updates (1.x.x)

### Extending to New Resource Types

To add support for additional AVM modules, you'll need to:

1. Add the resource type to `avm_resource_types` input
2. Create corresponding tfvars files in your environment directories
3. The action currently supports: `resource_groups`, `vnets`, `storage_accounts`

For other resource types, use the standard Terraform workflow mode instead of AVM mode.

### Combining with Standard Terraform

You cannot use both `enable_avm_mode` and `terraform_command` in the same workflow step. Choose one approach:

**Option 1: AVM Mode Only**
```yaml
- uses: Action-Foundry/tf-avm-action@v1
  with:
    enable_avm_mode: 'true'
    avm_environments: 'dev'
```

**Option 2: Standard Terraform Only**
```yaml
- uses: Action-Foundry/tf-avm-action@v1
  with:
    terraform_command: 'full'
    terraform_working_dir: './terraform'
```

**Option 3: Separate Steps**
```yaml
- name: Deploy AVM Resources
  uses: Action-Foundry/tf-avm-action@v1
  with:
    enable_avm_mode: 'true'
    avm_environments: 'dev'

- name: Deploy Custom Resources
  uses: Action-Foundry/tf-avm-action@v1
  with:
    terraform_command: 'full'
    terraform_working_dir: './terraform-custom'
```

## Troubleshooting

### Common Issues

#### Environment Directory Not Found

**Error**: `Environment directory not found: terraform/dev`

**Solution**: Create the directory and add at least one `.tfvars` file:
```bash
mkdir -p terraform/dev
# Then create resource_groups.tfvars or other tfvars files
```

#### No tfvars Files Found

**Warning**: `Skipping resource_groups: tfvars file not found`

**Solution**: The action skips resource types that don't have corresponding tfvars files. This is normal if you only want to deploy certain resource types.

#### Module Download Failures

**Error**: Module download or initialization failures

**Solution**: 
1. Ensure the runner has internet access to `registry.terraform.io`
2. Check that you're using a supported Terraform version (>= 1.5.0)
3. Verify no corporate proxy is blocking module downloads

#### Resource Already Exists

**Error**: Resource already exists in Azure

**Solution**:
1. Import existing resources: Use `terraform import` before running the action
2. Use unique names: Ensure resource names are unique, especially for storage accounts
3. Check backend state: Verify you're using the correct state file

#### Authentication Failures

**Error**: Azure authentication failed

**Solution**:
1. Verify service principal credentials are correct
2. Check that the service principal has appropriate permissions
3. Ensure OIDC federation is configured correctly if using OIDC
4. Run `azure/login` action before this action

### Getting Help

If you encounter issues:

1. Check the [Examples](examples/) directory for working configurations
2. Review the [README](README.md) for general action usage
3. Enable debug logging: Set `ACTIONS_STEP_DEBUG=true` repository secret
4. Open an [issue](https://github.com/Action-Foundry/tf-avm-action/issues) with:
   - Workflow configuration
   - Error messages
   - Tfvars file structure (sanitized)

## Additional Resources

- [Azure Verified Modules Registry](https://azure.github.io/Azure-Verified-Modules/)
- [Terraform Registry - AVM Modules](https://registry.terraform.io/search/modules?namespace=Azure&q=avm)
- [Azure Cloud Adoption Framework](https://docs.microsoft.com/azure/cloud-adoption-framework/)
- [Azure Naming Best Practices](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
- [Action Repository](https://github.com/Action-Foundry/tf-avm-action)

---

*For questions or feedback, please open a discussion or issue in the [repository](https://github.com/Action-Foundry/tf-avm-action).*
