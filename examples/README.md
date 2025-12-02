# Examples

This directory contains real-world examples of using tf-avm-action in various scenarios.

## 🚀 New Simplified Terraform Workflows

The action now includes built-in Terraform workflow commands for easier usage:

- [terraform-full-workflow.yml](terraform-full-workflow.yml) - ⭐ **NEW**: Simple `full` command (init + plan + apply)
- [terraform-plan-only.yml](terraform-plan-only.yml) - ⭐ **NEW**: `plan` command for PR reviews (init + plan)
- [terraform-destroy.yml](terraform-destroy.yml) - ⭐ **NEW**: `destroy` command to tear down infrastructure

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
