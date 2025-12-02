# tf-avm-action

[![CI](https://github.com/Action-Foundry/tf-avm-action/actions/workflows/ci.yml/badge.svg)](https://github.com/Action-Foundry/tf-avm-action/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Enterprise-grade Docker-based GitHub Action** providing a minimal, secure runtime with:

- **Terraform** - Infrastructure as Code tool
- **Azure CLI** - Command-line interface for Azure
- **GitHub CLI (gh)** - GitHub's official command line tool

## 🚀 Features

- **Version Control**: Pin specific versions or use `latest` for each tool
- **Lightweight**: Built on Alpine Linux for minimal image size
- **Secure**: Checksum verification for downloads, minimal attack surface
- **Enterprise-Ready**: Production-tested with comprehensive error handling
- **Multi-Architecture**: Supports `amd64` and `arm64`

## 📋 Inputs

### Tool Versions

| Input | Description | Default | Required |
|-------|-------------|---------|----------|
| `terraform_version` | Terraform version to install (e.g., `1.9.3`, `latest`) | `latest` | No |
| `azure_cli_version` | Azure CLI version to install (e.g., `2.64.0`, `latest`) | `latest` | No |
| `gh_cli_version` | GitHub CLI version to install (e.g., `2.63.1`, `latest`) | `latest` | No |

### Terraform Workflow (⭐ NEW)

| Input | Description | Default | Required |
|-------|-------------|---------|----------|
| `terraform_command` | Workflow command: `full` (init+plan+apply), `plan` (init+plan), `destroy` (init+plan+destroy), `none` (skip) | `none` | No |
| `terraform_working_dir` | Working directory for Terraform operations | `.` | No |
| `terraform_backend_config` | Backend configuration parameters (space-separated) | | No |
| `terraform_var_file` | Path to Terraform variables file | | No |
| `terraform_extra_args` | Additional arguments for Terraform commands | | No |

### Drift Detection (⭐ NEW)

| Input | Description | Default | Required |
|-------|-------------|---------|----------|
| `enable_drift_detection` | Enable drift detection with detailed exit codes | `false` | No |
| `drift_create_issue` | Create GitHub issue when drift is detected | `false` | No |

### Azure Authentication (⭐ NEW)

| Input | Description | Default | Required |
|-------|-------------|---------|----------|
| `azure_client_id` | Azure service principal client ID | | No |
| `azure_client_secret` | Azure service principal client secret (not needed for OIDC) | | No |
| `azure_subscription_id` | Azure subscription ID | | No |
| `azure_tenant_id` | Azure tenant ID | | No |
| `azure_use_oidc` | Use OIDC for Azure authentication | `false` | No |

### GitHub CLI Authentication (⭐ NEW)

| Input | Description | Default | Required |
|-------|-------------|---------|----------|
| `gh_token` | GitHub token (defaults to `GITHUB_TOKEN` if not provided) | | No |
| `gh_app_id` | GitHub App ID (alternative to token) | | No |
| `gh_app_private_key` | GitHub App private key (requires `gh_app_id`) | | No |

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `terraform_version_resolved` | The actual Terraform version that was installed |
| `azure_cli_version_resolved` | The actual Azure CLI version that was installed |
| `gh_cli_version_resolved` | The actual GitHub CLI version that was installed |
| `terraform_plan_exitcode` | Exit code from Terraform plan (0=no changes, 1=error, 2=changes) |
| `drift_detected` | Whether drift was detected (`true`/`false`) |

## 📖 Usage

> **💡 More Examples**: Check out the [examples/](examples/) directory for comprehensive real-world scenarios including the new simplified workflows, drift detection, and authentication options.

### 🚀 Quick Start: Simplified Terraform Workflow (⭐ NEW)

The easiest way to deploy infrastructure with this action:

```yaml
name: Infrastructure Deployment
on:
  push:
    branches: [main]

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
      
      - name: Deploy Infrastructure
        uses: Action-Foundry/tf-avm-action@v1
        with:
          terraform_command: 'full'  # Runs init + plan + apply
          terraform_working_dir: './terraform'
          azure_client_id: ${{ secrets.AZURE_CLIENT_ID }}
          azure_tenant_id: ${{ secrets.AZURE_TENANT_ID }}
          azure_subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          azure_use_oidc: 'true'
```

### Plan Only (for Pull Requests)

```yaml
- name: Terraform Plan
  uses: Action-Foundry/tf-avm-action@v1
  with:
    terraform_command: 'plan'  # Runs init + plan only
    terraform_working_dir: './terraform'
    azure_client_id: ${{ secrets.AZURE_CLIENT_ID }}
    azure_tenant_id: ${{ secrets.AZURE_TENANT_ID }}
    azure_subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    azure_use_oidc: 'true'
```

### 🔍 Drift Detection (⭐ NEW)

Automatically detect infrastructure drift and create GitHub issues:

```yaml
- name: Detect Drift
  uses: Action-Foundry/tf-avm-action@v1
  with:
    terraform_command: 'plan'
    terraform_working_dir: './terraform'
    enable_drift_detection: 'true'
    drift_create_issue: 'true'
    gh_token: ${{ secrets.GITHUB_TOKEN }}
    azure_use_oidc: 'true'
```

### Basic Tool Setup (No Terraform Execution)

```yaml
name: Infrastructure Deployment
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform + Azure CLI + GitHub CLI
        uses: Action-Foundry/tf-avm-action@v1
        # terraform_command defaults to 'none' - only installs tools
        
      - name: Verify tools
        run: |
          terraform --version
          az --version
          gh --version
```

### Pinned Versions

```yaml
name: Infrastructure Deployment
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform + Azure CLI + GitHub CLI
        uses: Action-Foundry/tf-avm-action@v1
        with:
          terraform_version: '1.9.3'
          azure_cli_version: '2.64.0'
          gh_cli_version: '2.63.1'
```

### Using Outputs

```yaml
name: Infrastructure Deployment
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform + Azure CLI + GitHub CLI
        id: setup
        uses: Action-Foundry/tf-avm-action@v1
        
      - name: Display installed versions
        run: |
          echo "Terraform: ${{ steps.setup.outputs.terraform_version_resolved }}"
          echo "Azure CLI: ${{ steps.setup.outputs.azure_cli_version_resolved }}"
          echo "GitHub CLI: ${{ steps.setup.outputs.gh_cli_version_resolved }}"
```

### Service Principal Authentication (Alternative to OIDC)

```yaml
- name: Deploy with Service Principal
  uses: Action-Foundry/tf-avm-action@v1
  with:
    terraform_command: 'full'
    terraform_working_dir: './terraform'
    
    # Service Principal authentication
    azure_client_id: ${{ secrets.AZURE_CLIENT_ID }}
    azure_client_secret: ${{ secrets.AZURE_CLIENT_SECRET }}
    azure_subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    azure_tenant_id: ${{ secrets.AZURE_TENANT_ID }}
    azure_use_oidc: 'false'
```

### Destroy Infrastructure

```yaml
- name: Destroy Infrastructure
  uses: Action-Foundry/tf-avm-action@v1
  with:
    terraform_command: 'destroy'  # Runs init + plan + destroy
    terraform_working_dir: './terraform'
    azure_use_oidc: 'true'
```

## 🎯 Terraform Workflow Commands

The action now provides three intuitive workflow commands:

| Command | Actions | Use Case |
|---------|---------|----------|
| `full` | init → plan → apply | Deploy infrastructure |
| `plan` | init → plan | Review changes (PRs) |
| `destroy` | init → plan → destroy | Tear down infrastructure |
| `none` | (skip) | Only install tools |

## 🔒 Security Considerations

### Download Verification

- **Terraform**: Downloads are verified using SHA256 checksums from HashiCorp's official release metadata
- **Azure CLI**: Installed via pip from PyPI with package integrity verification
- **GitHub CLI**: Downloads are verified using SHA256 checksums from official GitHub releases

### Image Security

- Built on **Alpine Linux 3.21.0** - minimal base image with security updates
- **Non-essential packages removed** - only required dependencies installed
- **No cached credentials** - clean image without stored secrets
- **Regular updates** - base image updated with security patches

For more security information, see our [Security Policy](SECURITY.md).

### Best Practices

1. **Pin versions in production** - Use specific versions rather than `latest` for reproducible builds
2. **Use OIDC authentication** - Prefer OpenID Connect over long-lived secrets for Azure authentication
3. **Review changes** - Always review infrastructure changes before applying

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Alpine Linux 3.21                       │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │  Terraform  │  │  Azure CLI  │  │  GitHub CLI │          │
│  │   (latest)  │  │   (latest)  │  │   (latest)  │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
├─────────────────────────────────────────────────────────────┤
│  Core Dependencies: bash, curl, git, jq, python3            │
└─────────────────────────────────────────────────────────────┘
```

## 📦 Available Tool Versions

For detailed version compatibility information, see [COMPATIBILITY.md](COMPATIBILITY.md).

### Terraform

Find available versions at: https://releases.hashicorp.com/terraform/

### Azure CLI

Find available versions at: https://pypi.org/project/azure-cli/#history

### GitHub CLI

Find available versions at: https://github.com/cli/cli/releases

## 🐛 Troubleshooting

### Version Not Found

If you see an error about a version not being found:

1. Verify the version exists in the official releases
2. Check for typos in the version string
3. Ensure you're not including the `v` prefix (it's automatically handled)

### Download Failures

If downloads fail:

1. Check GitHub Actions runner has internet access
2. Verify no corporate proxy is blocking downloads
3. Try a specific version instead of `latest`

### Azure CLI Authentication Issues

If Azure CLI authentication fails:

1. Verify your service principal credentials
2. Check that the service principal has appropriate permissions
3. Consider using OIDC authentication for better security

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📊 Metrics and Performance

This action is built with measurable performance goals and quality standards. See [METRICS.md](METRICS.md) for detailed performance metrics, benchmarks, and success criteria.

**Key Metrics**:
- ⚡ Installation time: <90s (cold start), <20s (cached)
- 🎯 Reliability: >99.5% success rate
- 🔒 Security: 100% checksum verification
- 📦 Image size: ~250-300 MB

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/Action-Foundry/tf-avm-action/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Action-Foundry/tf-avm-action/discussions)