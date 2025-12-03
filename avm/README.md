# AVM Modules Directory

This directory contains self-contained Terraform modules for Azure Verified Modules (AVM). Each module is designed to be independent and fully functional, referencing the official AVM modules from the Terraform Registry.

## Directory Structure

```
avm/
├── README.md                    # This file
├── _template/                   # Template for creating new AVM modules
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
├── resource_groups/             # Resource Groups module
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
├── vnets/                       # Virtual Networks module
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
└── storage_accounts/            # Storage Accounts module
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

## Module Design Principles

Each module in this directory follows these principles:

1. **Self-Contained**: Each module contains all necessary Terraform configuration files (main.tf, variables.tf, outputs.tf)
2. **AVM Integration**: Modules reference official Azure Verified Modules from the Terraform Registry
3. **CAF Compliance**: Built-in support for Azure Cloud Adoption Framework naming and tagging
4. **Environment-Aware**: Support for environment-based deployments (dev, test, uat, staging, prod)
5. **Independent**: Each module can be used independently or via the avm-deploy.sh script
6. **Documented**: Each module includes comprehensive README.md documentation

## Available Modules

### Core Modules (Ready to Use)

| Module | Description | AVM Source |
|--------|-------------|------------|
| [resource_groups](./resource_groups/) | Azure Resource Groups | [Azure/avm-res-resources-resourcegroup/azurerm](https://registry.terraform.io/modules/Azure/avm-res-resources-resourcegroup/azurerm) |
| [vnets](./vnets/) | Azure Virtual Networks with Subnets | [Azure/avm-res-network-virtualnetwork/azurerm](https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm) |
| [storage_accounts](./storage_accounts/) | Azure Storage Accounts | [Azure/avm-res-storage-storageaccount/azurerm](https://registry.terraform.io/modules/Azure/avm-res-storage-storageaccount/azurerm) |

### Template Module

The `_template/` directory provides a starting point for creating new AVM modules. See [Adding New Modules](#adding-new-modules) below.

## Using Modules Independently

Each module can be used directly in your Terraform configuration:

```hcl
# Example: Using the resource_groups module
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
      }
    }
  }
}
```

## Using with avm-deploy.sh

The `avm-deploy.sh` script automatically uses these modules when deploying resources:

```bash
# The script will use modules from avm/ directory
./scripts/avm-deploy.sh true "dev" "resource_groups,vnets,storage_accounts" "eastus" "./terraform"
```

## Module Structure

Each module follows a consistent structure:

### main.tf
Contains:
- Terraform and provider requirements
- Module block calling the official AVM module
- Resource configuration with for_each for multiple resources
- Standard tagging

### variables.tf
Defines:
- Resource-specific variable (map of objects)
- `default_location` variable
- `environment` variable
- Optional parameters with sensible defaults

### outputs.tf
Provides:
- Resource IDs output map
- Resource names output map
- Additional module-specific outputs as needed

### README.md
Documents:
- Module overview and purpose
- Usage examples (independent and with tfvars)
- Input variables
- Output values
- Resource object structure
- CAF naming conventions
- Requirements and dependencies

## Adding New Modules

To add support for additional AVM modules:

### 1. Create Module Directory

```bash
cd avm
cp -r _template/ <module_name>/
cd <module_name>
```

### 2. Update Module Files

Replace placeholders in the copied files:

- `[MODULE_DISPLAY_NAME]`: Human-readable module name (e.g., "Key Vault")
- `[MODULE_VAR_NAME]`: Variable name (e.g., "keyvault_vault")
- `[MODULE_SOURCE]`: Full Terraform registry path (e.g., "Azure/avm-res-keyvault-vault/azurerm")
- `[MODULE_SOURCE_SHORT]`: Short module name (e.g., "avm-res-keyvault-vault")
- `[RESOURCE_NAME_EXAMPLE]`: Example resource name (e.g., "kv-myapp-dev-eastus-001")

### 3. Customize for Module-Specific Requirements

Some modules may require:
- Additional required parameters in variables.tf
- Custom configuration in main.tf
- Special handling for nested objects (like subnets in VNets)

See `vnets/` and `storage_accounts/` modules for examples of customization.

### 4. Update avm-modules-registry.sh

If using the generic template generator in avm-deploy.sh, ensure the module is registered in `scripts/lib/avm-modules-registry.sh`.

### 5. Test the Module

```bash
cd <module_name>
terraform init
terraform validate
terraform plan -var-file=<test>.tfvars -var="environment=dev" -var="default_location=eastus"
```

### 6. Document Usage

Update the module's README.md with:
- Specific usage examples
- Required and optional parameters
- CAF naming conventions for the resource type
- Any dependencies or prerequisites

## Module Independence

Each module in this directory is designed to be independent:

1. **No Cross-Module Dependencies**: Modules don't directly depend on each other's outputs
2. **Standalone Usage**: Each can be used in isolation
3. **Consistent Interface**: All modules use the same variable patterns (environment, default_location)
4. **Self-Contained Configuration**: All Terraform configuration needed is in the module directory

However, resource dependencies (e.g., VNets requiring Resource Groups) are managed through:
- User-provided `resource_group_name` parameters in tfvars
- Deployment order in avm-deploy.sh (resource_groups deployed first)
- Terraform's dependency resolution when used independently

## Standard Variables

All modules support these standard variables:

| Variable | Type | Description | Required |
|----------|------|-------------|----------|
| `environment` | string | Environment name (dev, test, uat, staging, prod) | Yes |
| `default_location` | string | Default Azure region for resources | Yes |
| `<resource_type>` | map(object) | Map of resources to create | No (defaults to {}) |

## Standard Tags

All modules automatically apply these tags:

- `environment`: From the environment variable
- `managed_by`: Always "terraform"
- `module`: The AVM module name

Additional tags can be provided in the resource definitions.

## All 102 AVM Modules Support

While only three modules have dedicated directories currently, the action supports all 102 AVM modules through:

1. **Dedicated Modules** (in this directory): resource_groups, vnets, storage_accounts
2. **Generic Template Generator** (in avm-template-generator.sh): Used for other 99 modules
3. **Registry-Driven** (in avm-modules-registry.sh): All modules are cataloged

To get dedicated directory support for additional modules, follow the [Adding New Modules](#adding-new-modules) section.

## References

- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [Terraform Registry - AVM Modules](https://registry.terraform.io/search/modules?namespace=Azure&q=avm)
- [Azure CAF Best Practices](https://docs.microsoft.com/azure/cloud-adoption-framework/)
- [Main AVM_MODULES.md](../AVM_MODULES.md) - Comprehensive AVM documentation

## Contributing

When adding new modules to this directory:

1. Follow the existing module structure
2. Use the _template as a starting point
3. Ensure all four files are present (main.tf, variables.tf, outputs.tf, README.md)
4. Test the module independently before integration
5. Update this README.md to list the new module
6. Follow CAF naming conventions in examples

## Version Requirements

All modules require:
- Terraform >= 1.5.0
- Azure Provider (hashicorp/azurerm) ~> 3.0
- Corresponding AVM module version ~> 0.1
