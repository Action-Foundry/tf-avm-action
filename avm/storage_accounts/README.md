# Storage Accounts AVM Module

This module provides a self-contained Terraform configuration for deploying Azure Storage Accounts using the [Azure Verified Module for Storage Accounts](https://registry.terraform.io/modules/Azure/avm-res-storage-storageaccount/azurerm).

## Overview

This module wraps the official AVM module for Storage Accounts and provides:
- CAF-compliant naming and tagging
- Support for multiple storage accounts in a single deployment
- Configurable storage tiers, replication types, and account kinds
- Environment-based configuration
- Default location configuration with per-resource override capability

## Usage

This module is designed to be used by the `avm-deploy.sh` script but can also be used independently.

### Independent Usage

```hcl
module "storage_accounts" {
  source = "./avm/storage_accounts"
  
  environment      = "dev"
  default_location = "eastus"
  
  storage_accounts = {
    sa1 = {
      name                     = "stmyappdeveastus001"
      location                 = "eastus"
      resource_group_name      = "rg-myapp-dev-eastus-001"
      account_tier             = "Standard"
      account_replication_type = "LRS"
      account_kind             = "StorageV2"
      tags = {
        cost_center         = "engineering"
        data_classification = "internal"
      }
    }
  }
}
```

### With tfvars File

Create a `storage_accounts.tfvars` file:

```hcl
storage_accounts = {
  sa1 = {
    name                     = "stmyappdeveastus001"
    location                 = "eastus"
    resource_group_name      = "rg-myapp-dev-eastus-001"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    account_kind             = "StorageV2"
    tags = {
      cost_center         = "engineering"
      data_classification = "internal"
    }
  }
}
```

Then use:

```bash
terraform init
terraform plan -var-file=storage_accounts.tfvars -var="environment=dev" -var="default_location=eastus"
terraform apply -var-file=storage_accounts.tfvars -var="environment=dev" -var="default_location=eastus"
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| storage_accounts | Map of storage accounts to create | `map(object)` | `{}` | no |
| default_location | Default location for resources if not specified | `string` | n/a | yes |
| environment | Environment name (dev, test, uat, staging, prod) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| storage_account_ids | Map of storage account IDs |
| storage_account_names | Map of storage account names |

## Storage Account Object Structure

Each storage account in the `storage_accounts` map should have:

```hcl
{
  name                     = string                        # Storage account name (required)
  location                 = optional(string)              # Azure region (optional, uses default_location if not set)
  resource_group_name      = string                        # Resource group name (required)
  account_tier             = optional(string, "Standard")  # Standard or Premium (optional, default: Standard)
  account_replication_type = optional(string, "LRS")       # LRS, GRS, RAGRS, ZRS (optional, default: LRS)
  account_kind             = optional(string, "StorageV2") # StorageV2, BlobStorage, FileStorage (optional, default: StorageV2)
  tags                     = optional(map(string))         # Additional tags (optional)
}
```

## CAF Naming Convention

Follow Azure Cloud Adoption Framework naming conventions:

```
st<workload><environment><region><instance>
Example: stmyappdeveastus001
```

**Important Naming Requirements:**
- Storage account names must be globally unique across all of Azure
- Must be 3-24 characters long
- Only lowercase letters and numbers (no hyphens or special characters)

## Tags

Standard tags automatically applied by this module:
- `environment`: Set from the environment variable
- `managed_by`: Always set to "terraform"
- `module`: Always set to "avm-res-storage-storageaccount"

Additional tags can be provided via the `tags` attribute in each storage account definition.

Recommended additional tags for storage accounts:
- `data_classification`: e.g., "public", "internal", "confidential", "restricted"
- `backup`: e.g., "required", "not-required"
- `retention`: e.g., "30days", "1year", "7years"

## Storage Configuration Options

### Account Tier
- `Standard`: Standard performance tier (HDD-backed)
- `Premium`: Premium performance tier (SSD-backed)

### Replication Type
- `LRS`: Locally Redundant Storage
- `GRS`: Geo-Redundant Storage
- `RAGRS`: Read-Access Geo-Redundant Storage
- `ZRS`: Zone-Redundant Storage
- `GZRS`: Geo-Zone-Redundant Storage
- `RAGZRS`: Read-Access Geo-Zone-Redundant Storage

### Account Kind
- `StorageV2`: General-purpose v2 (recommended for most scenarios)
- `BlobStorage`: Blob storage only
- `FileStorage`: Premium file shares
- `BlockBlobStorage`: Premium block blob storage

## Requirements

- Terraform >= 1.5.0
- Azure Provider ~> 3.0
- Azure Verified Module: Azure/avm-res-storage-storageaccount/azurerm ~> 0.1

## Dependencies

Resource groups referenced in `resource_group_name` must exist before deploying storage accounts.

## References

- [AVM Storage Account Module](https://registry.terraform.io/modules/Azure/avm-res-storage-storageaccount/azurerm)
- [Azure CAF Naming Best Practices](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
- [Azure Storage Account Types](https://docs.microsoft.com/azure/storage/common/storage-account-overview)
