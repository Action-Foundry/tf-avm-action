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

| Input | Description | Default | Required |
|-------|-------------|---------|----------|
| `terraform_version` | Terraform version to install (e.g., `1.9.3`, `latest`) | `latest` | No |
| `azure_cli_version` | Azure CLI version to install (e.g., `2.64.0`, `latest`) | `latest` | No |
| `gh_cli_version` | GitHub CLI version to install (e.g., `2.63.1`, `latest`) | `latest` | No |

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `terraform_version_resolved` | The actual Terraform version that was installed |
| `azure_cli_version_resolved` | The actual Azure CLI version that was installed |
| `gh_cli_version_resolved` | The actual GitHub CLI version that was installed |

## 📖 Usage

### Basic Usage (Latest Versions)

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

### Complete Terraform + Azure Workflow

```yaml
name: Terraform Azure Deployment
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
  ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
  ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
  ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform + Azure CLI + GitHub CLI
        uses: Action-Foundry/tf-avm-action@v1
        with:
          terraform_version: '1.9.3'

      - name: Azure Login
        run: |
          az login --service-principal \
            -u $ARM_CLIENT_ID \
            -p $ARM_CLIENT_SECRET \
            --tenant $ARM_TENANT_ID

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan -out=tfplan

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve tfplan
```

## 🔒 Security Considerations

### Download Verification

- **Terraform**: Downloads are verified using SHA256 checksums from HashiCorp's official release metadata
- **Azure CLI**: Installed via pip from PyPI with package integrity verification
- **GitHub CLI**: Downloaded from official GitHub releases

### Image Security

- Built on **Alpine Linux 3.21** - minimal base image with security updates
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

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/Action-Foundry/tf-avm-action/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Action-Foundry/tf-avm-action/discussions)