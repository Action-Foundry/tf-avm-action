# Examples

This directory contains real-world examples of using tf-avm-action in various scenarios.

## 🆕 Azure Verified Modules (AVM) - ALL 102 MODULES SUPPORTED!

Deploy Azure resources following CAF best practices with pre-validated modules:

**🎉 All 102 AVM Modules Now Supported!**

- [avm-single-environment.yml](avm-single-environment.yml) - Deploy to a single environment (dev)
- [avm-multi-environment.yml](avm-multi-environment.yml) - Deploy to multiple environments sequentially
- [avm-matrix-deployment.yml](avm-matrix-deployment.yml) - Deploy to multiple environments in parallel
- [avm-extended-modules.yml](avm-extended-modules.yml) - 🆕 **NEW**: Deploy using extended modules (Key Vault, SQL, AKS, etc.)
- [terraform-configs/dev/](terraform-configs/dev/) - Example tfvars files for basic modules
- [terraform-configs/dev-extended/](terraform-configs/dev-extended/) - 🆕 **NEW**: Example tfvars for extended modules
- [terraform-configs/prod/](terraform-configs/prod/) - Production environment examples

**Supported Module Categories:**
- 💾 **Storage & Data**: Storage Accounts, SQL Server, MySQL, PostgreSQL, Cosmos DB
- 🌐 **Networking**: VNets, Load Balancers, Application Gateway, Firewall, DNS, VPN
- 🔐 **Security & Identity**: Key Vault, Managed Identity, Role Assignments
- 🖥️ **Compute**: Virtual Machines, VM Scale Sets, Container Instances, AKS
- 📊 **Monitoring**: Application Insights, Log Analytics, Data Collection
- 📦 **Containers**: Container Registry, Container Apps, AKS
- 🔄 **Integration**: Event Hub, Service Bus, Logic Apps, Data Factory
- 🖼️ **Web**: App Service, Function Apps, Static Web Apps
- ...and 80+ more!

> **📚 Complete Guide**: See [AVM_MODULES.md](../AVM_MODULES.md) for the full list of 102 supported modules and comprehensive documentation.

## 🚀 Simplified Terraform Workflows

The action includes built-in Terraform workflow commands for easier usage:

- [terraform-full-workflow.yml](terraform-full-workflow.yml) - ⭐ Simple `full` command (init + plan + apply)
- [terraform-plan-only.yml](terraform-plan-only.yml) - ⭐ `plan` command for PR reviews (init + plan)
- [terraform-destroy.yml](terraform-destroy.yml) - ⭐ `destroy` command to tear down infrastructure

## 🔍 Enhanced Drift Detection

- [drift-detection-simple.yml](drift-detection-simple.yml) - ⭐ **NEW**: Simplified drift detection with auto-issue creation
- [scheduled-drift-detection.yml](scheduled-drift-detection.yml) - Manual drift detection example

## 🔐 Authentication Examples

- [azure-service-principal-auth.yml](azure-service-principal-auth.yml) - ⭐ **NEW**: Service Principal authentication
- [oidc-authentication.yml](oidc-authentication.yml) - OIDC authentication (most secure)

## 📦 Basic Setup Examples

- [tools-only-setup.yml](tools-only-setup.yml) - ⭐ **NEW**: Install tools without running Terraform
- [basic-usage.yml](basic-usage.yml) - Simple setup with latest versions
- [pinned-versions.yml](pinned-versions.yml) - Production-ready with pinned tool versions

## 🏗️ Advanced Workflows

- [azure-deployment.yml](azure-deployment.yml) - Complete Azure infrastructure deployment
- [multi-environment.yml](multi-environment.yml) - Deploy to multiple environments (dev, staging, prod)
- [pr-plan-workflow.yml](pr-plan-workflow.yml) - Terraform plan on pull requests

## Quick Start Guide

### 1. Simple Deployment (Recommended)
Use the new `terraform_command` input for the easiest experience:

```yaml
- uses: Action-Foundry/tf-avm-action@v1
  with:
    terraform_command: 'full'  # init + plan + apply
    terraform_working_dir: './terraform'
    azure_client_id: ${{ secrets.AZURE_CLIENT_ID }}
    azure_tenant_id: ${{ secrets.AZURE_TENANT_ID }}
    azure_subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    azure_use_oidc: 'true'
```

### 2. Plan-Only (for PRs)
```yaml
- uses: Action-Foundry/tf-avm-action@v1
  with:
    terraform_command: 'plan'  # init + plan only
    terraform_working_dir: './terraform'
```

### 3. Drift Detection
```yaml
- uses: Action-Foundry/tf-avm-action@v1
  with:
    terraform_command: 'plan'
    enable_drift_detection: 'true'
    drift_create_issue: 'true'
    azure_client_id: ${{ secrets.AZURE_CLIENT_ID }}
    azure_tenant_id: ${{ secrets.AZURE_TENANT_ID }}
    azure_subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    azure_use_oidc: 'true'
```

## Usage

Copy the example that best matches your use case and adapt it to your needs. Each example includes:

- Clear comments explaining each step
- Best practices for security and reliability
- Links to relevant documentation

## Contributing

If you have a useful workflow pattern, please contribute it as an example! See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.
