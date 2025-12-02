# Example Terraform Configurations for AVM

This directory contains example `.tfvars` files for deploying Azure resources using Azure Verified Modules (AVM) with the tf-avm-action.

## Directory Structure

```
terraform-configs/
├── dev/                        # Development environment
│   ├── resource_groups.tfvars
│   ├── vnets.tfvars
│   └── storage_accounts.tfvars
└── prod/                       # Production environment
    ├── resource_groups.tfvars
    ├── vnets.tfvars
    └── storage_accounts.tfvars
```

## How to Use

### 1. Copy to Your Repository

Copy the environment folders you need to your repository's `terraform/` directory:

```bash
# From your repository root
cp -r examples/terraform-configs/dev terraform/
cp -r examples/terraform-configs/prod terraform/
```

### 2. Customize for Your Environment

Update the tfvars files with your specific values:

- **Resource names**: Update to match your naming convention
- **Locations**: Change Azure regions as needed
- **Tags**: Add your organization's required tags
- **Address spaces**: Adjust network CIDR blocks
- **Storage names**: Must be globally unique (3-24 chars, lowercase, no hyphens)

### 3. Configure Your Workflow

Use the example workflows from the `examples/` directory:

- `avm-single-environment.yml` - Deploy to one environment
- `avm-multi-environment.yml` - Deploy to multiple environments sequentially
- `avm-matrix-deployment.yml` - Deploy to multiple environments in parallel

## Key Differences Between Environments

### Development (dev/)

- **Lower redundancy**: LRS (Locally Redundant Storage) for cost savings
- **Simpler networking**: Basic subnet structure
- **Minimal tags**: Basic cost center and owner tags

### Production (prod/)

- **Higher redundancy**: GRS/RAGRS (Geo-Redundant Storage) for data protection
- **Enhanced networking**: Additional subnets for firewall, integration
- **Comprehensive tags**: Includes backup, DR tier, and compliance tags
- **Production-grade config**: Follows enterprise security standards

## Azure Naming Convention

These examples follow Azure Cloud Adoption Framework (CAF) naming conventions:

| Resource | Format | Example |
|----------|--------|---------|
| Resource Group | `rg-<workload>-<env>-<region>-<###>` | `rg-myapp-dev-eastus-001` |
| VNet | `vnet-<workload>-<env>-<region>-<###>` | `vnet-myapp-dev-eastus-001` |
| Subnet | `snet-<purpose>-<env>-<###>` | `snet-web-dev-001` |
| Storage Account | `st<workload><env><region><###>` | `stmyappdeveastus001` |

**Special Azure-required names**:
- VPN Gateway subnet: `GatewaySubnet` (exact name required)
- Bastion subnet: `AzureBastionSubnet` (exact name required)
- Firewall subnet: `AzureFirewallSubnet` (exact name required)

## Storage Account Naming Rules

Storage account names have strict requirements:
- **3-24 characters**
- **Lowercase letters and numbers only**
- **No hyphens or special characters**
- **Must be globally unique across all of Azure**

Example: `stmyappdeveastus001`

## Tags Strategy

### Automatic Tags (added by the action)

```hcl
environment = "dev"
managed_by  = "terraform"
module      = "avm-res-..."
```

### Recommended Additional Tags

**Development**:
```hcl
tags = {
  cost_center = "engineering"
  owner       = "platform-team"
  project     = "myapp"
}
```

**Production**:
```hcl
tags = {
  cost_center         = "engineering"
  owner               = "platform-team"
  project             = "myapp"
  backup              = "required"
  dr_tier             = "tier1"
  data_classification = "confidential"
}
```

## Network Address Planning

### Development
- App VNet: `10.0.0.0/16`
- Shared VNet: `10.1.0.0/16`

### Production
- App VNet: `10.100.0.0/16`
- Shared VNet: `10.101.0.0/16`

This allows for:
- Clear separation between environments
- Room for growth (65,536 IPs per /16)
- Easy identification of environment by IP range

## Resource Dependencies

Deploy in this order:
1. **Resource Groups** - Must exist first
2. **Virtual Networks** - References resource groups
3. **Storage Accounts** - References resource groups

The action handles this automatically when you specify:
```yaml
avm_resource_types: 'resource_groups,vnets,storage_accounts'
```

## Extending to Other Environments

To add test, uat, or staging environments:

```bash
mkdir terraform/test
mkdir terraform/uat
mkdir terraform/staging
```

Then copy and customize tfvars files from dev or prod as templates.

## Additional Resources

- [Azure Naming Convention Best Practices](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [AVM Modules Documentation](../AVM_MODULES.md)

## Need Help?

- Review the [AVM_MODULES.md](../AVM_MODULES.md) for detailed documentation
- Check the [example workflows](../) for usage patterns
- Open an [issue](https://github.com/Action-Foundry/tf-avm-action/issues) if you encounter problems
