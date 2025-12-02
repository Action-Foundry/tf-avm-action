# Security Policy

## Reporting a Vulnerability

The Action-Foundry team takes the security of our projects seriously. We appreciate your efforts to responsibly disclose any security vulnerabilities you may find.

### How to Report

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via one of the following methods:

1. **GitHub Security Advisories**: Use the [Security Advisories](https://github.com/Action-Foundry/tf-avm-action/security/advisories) feature to privately report vulnerabilities.

2. **Email**: Send details to the repository maintainers through GitHub's private messaging system.

### What to Include

When reporting a vulnerability, please include:

- A description of the vulnerability
- Steps to reproduce the issue
- Potential impact of the vulnerability
- Any possible mitigations you've identified

### Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 5 business days
- **Resolution Target**: Within 30 days for critical issues

## Security Best Practices for Users

### Pin Action Versions

Always pin to a specific version or commit SHA rather than using `@main` or `@latest`:

```yaml
# ✅ Recommended - pin to specific version
- uses: Action-Foundry/tf-avm-action@v1.0.0

# ✅ Most secure - pin to commit SHA
- uses: Action-Foundry/tf-avm-action@abc123def456

# ❌ Not recommended - mutable reference
- uses: Action-Foundry/tf-avm-action@main
```

### Pin Tool Versions

For production workflows, pin specific tool versions rather than using `latest`:

```yaml
- uses: Action-Foundry/tf-avm-action@v1
  with:
    terraform_version: '1.9.3'
    azure_cli_version: '2.64.0'
    gh_cli_version: '2.63.1'
```

### Secrets Management

- Never hardcode secrets in your workflow files
- Use GitHub's encrypted secrets feature
- Prefer OIDC authentication over long-lived credentials for Azure
- Regularly rotate credentials

```yaml
# ✅ Use GitHub secrets
env:
  ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}

# ✅ Even better - use OIDC
- uses: azure/login@v2
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

### Workflow Permissions

Follow the principle of least privilege for workflow permissions:

```yaml
permissions:
  contents: read
  # Only add additional permissions as needed
```

## Security Measures in This Action

### Download Verification

- **Terraform**: Downloads are verified using SHA256 checksums from HashiCorp's official release metadata
- **Azure CLI**: Installed via pip from PyPI with package integrity verification
- **GitHub CLI**: Downloaded from official GitHub releases

### Container Security

- Built on **Alpine Linux 3.21** - minimal base image with regular security updates
- Non-essential packages are not installed
- No cached credentials in the image
- Dependencies are regularly updated via Dependabot

### Supply Chain Security

- GitHub Actions used in CI/CD are pinned to specific versions
- Dependabot monitors for security updates in dependencies
- Regular security audits of the codebase

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| v1.x    | :white_check_mark: |
| < v1.0  | :x:                |

## Security Updates

Security updates are released as patch versions and are announced via:

- GitHub Security Advisories
- Release notes
- Repository README badges
