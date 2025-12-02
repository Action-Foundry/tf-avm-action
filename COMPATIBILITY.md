# Tool Version Compatibility Matrix

This document tracks the compatibility of tool versions with tf-avm-action and provides guidance on version selection.

## Supported Tool Versions

### Terraform

| Version Range | Status | Notes |
|--------------|--------|-------|
| 1.9.x | ✅ Fully Supported | Latest stable release series |
| 1.8.x | ✅ Fully Supported | Previous stable release |
| 1.7.x | ✅ Supported | Older stable release |
| 1.6.x | ✅ Supported | Older stable release |
| 1.5.x | ✅ Supported | Older stable release |
| < 1.5.0 | ⚠️ Use with caution | Very old versions |
| 0.x | ❌ Not recommended | Legacy versions |

**Recommended for Production**: `1.9.3` or latest 1.9.x

### Azure CLI

| Version Range | Status | Notes |
|--------------|--------|-------|
| 2.64.x | ✅ Fully Supported | Latest stable release |
| 2.63.x | ✅ Fully Supported | Previous stable release |
| 2.60.x - 2.62.x | ✅ Supported | Recent releases |
| 2.50.x - 2.59.x | ✅ Supported | Older releases |
| < 2.50.0 | ⚠️ Use with caution | Very old versions |

**Recommended for Production**: `2.64.0` or latest 2.x

### GitHub CLI

| Version Range | Status | Notes |
|--------------|--------|-------|
| 2.63.x | ✅ Fully Supported | Latest stable release |
| 2.62.x | ✅ Fully Supported | Previous stable release |
| 2.60.x - 2.61.x | ✅ Supported | Recent releases |
| 2.50.x - 2.59.x | ✅ Supported | Older releases |
| < 2.50.0 | ⚠️ Use with caution | Very old versions |

**Recommended for Production**: `2.63.1` or latest 2.x

## Architecture Support

| Architecture | Terraform | Azure CLI | GitHub CLI |
|-------------|-----------|-----------|------------|
| amd64 (x86_64) | ✅ | ✅ | ✅ |
| arm64 (aarch64) | ✅ | ✅ | ✅ |

## Runner Compatibility

### GitHub-Hosted Runners

| Runner | Status | Notes |
|--------|--------|-------|
| ubuntu-latest | ✅ Fully Supported | Recommended |
| ubuntu-24.04 | ✅ Fully Supported | Latest LTS |
| ubuntu-22.04 | ✅ Fully Supported | LTS |
| ubuntu-20.04 | ✅ Supported | Older LTS |

### Self-Hosted Runners

Self-hosted runners are supported if they meet these requirements:
- Docker support
- Internet access to download tools
- Sufficient disk space (minimum 2GB recommended)

## Performance Characteristics

### Installation Times (Typical)

| Configuration | Average Time | Notes |
|--------------|-------------|-------|
| Latest versions (first run) | 60-90 seconds | Includes all downloads |
| Pinned versions (first run) | 50-80 seconds | Slightly faster due to specific versions |
| With Docker layer caching | 10-20 seconds | Cached layers significantly reduce time |

### Image Size

- Base Alpine Linux: ~7 MB
- With all tools installed: ~200-300 MB
- Docker image layers enable efficient caching

## Version Update Policy

### When to Update

1. **Security patches**: Update immediately for critical vulnerabilities
2. **Major releases**: Test in non-production first, then update within 1-2 weeks
3. **Minor releases**: Update within 1 month after release
4. **Patch releases**: Update at next maintenance window

### Testing Strategy

Before updating tool versions in production:

1. Test in a development environment
2. Run your full test suite
3. Validate all workflows function correctly
4. Monitor for any deprecation warnings
5. Check release notes for breaking changes

## Troubleshooting Version Issues

### Version Not Found

If you receive a "version not found" error:

1. Verify the version exists in the official releases:
   - Terraform: https://releases.hashicorp.com/terraform/
   - Azure CLI: https://pypi.org/project/azure-cli/#history
   - GitHub CLI: https://github.com/cli/cli/releases

2. Check for typos in the version string
3. Ensure you're not including the `v` prefix (handled automatically)
4. Try using `latest` to verify connectivity

### Compatibility Issues

If you experience compatibility issues:

1. Check this compatibility matrix
2. Review the tool's official release notes
3. Test with the recommended versions listed above
4. Open an issue with details: version numbers, error messages, workflow file

## Staying Updated

- Watch the [Releases page](https://github.com/Action-Foundry/tf-avm-action/releases) for action updates
- Subscribe to tool release notifications:
  - [Terraform Releases](https://github.com/hashicorp/terraform/releases)
  - [Azure CLI Releases](https://github.com/Azure/azure-cli/releases)
  - [GitHub CLI Releases](https://github.com/cli/cli/releases)

## Version Support Lifecycle

- **Current**: Actively maintained and recommended
- **Supported**: Still works but not actively tested
- **Use with caution**: May work but not recommended
- **Not recommended**: Known issues or security concerns

Last updated: 2025-12-02
