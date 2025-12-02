# Roadmap

This document outlines the planned features and improvements for tf-avm-action.

## Version 1.x (Current)

### ✅ Completed

- Docker-based action with Alpine Linux
- Support for Terraform, Azure CLI, and GitHub CLI
- Version pinning and "latest" support
- Multi-architecture support (amd64, arm64)
- SHA256 checksum verification
- Comprehensive documentation
- CI/CD pipeline with testing
- Security best practices
- Example workflows
- Unit testing framework
- Performance metrics
- **🆕 Azure Verified Modules (AVM) support**
  - Multi-environment deployment (dev, test, uat, staging, prod)
  - Tfvars-driven configuration
  - Support for resource groups, VNets, and storage accounts
  - Azure CAF naming conventions and tagging standards
  - Comprehensive documentation and examples

### 🔄 In Progress

- Community adoption and feedback
- Performance optimizations
- Enhanced error messages

## Version 1.1 (Q1 2026)

### Planned Features

- **Caching Improvements**
  - Implement tool version caching to speed up repeated runs
  - Smart cache invalidation based on version changes
  - Reduce cold start time to <60 seconds

- **Enhanced Validation**
  - Pre-download validation of version availability
  - Better error messages with actionable suggestions
  - Automatic retry with fallback versions

- **Additional Tools (Optional)**
  - Terragrunt support
  - Ansible support (optional)
  - Packer support (optional)

- **Monitoring & Observability**
  - Structured logging output
  - JSON output format option
  - Telemetry for usage analytics (opt-in)

## Version 1.2 (Q2 2026)

### Planned Features

- **Advanced Configuration**
  - Custom installation directories
  - Plugin/provider pre-installation for Terraform
  - Custom CA certificates support

- **Performance Enhancements**
  - Parallel tool installation
  - Optimized Docker layer structure
  - Mirror support for faster downloads in specific regions

- **Quality of Life**
  - Auto-update notifications
  - Version compatibility warnings
  - Smart defaults based on project detection

## Version 2.0 (Q3-Q4 2026)

### Major Features

- **Multi-Cloud Support**
  - AWS CLI support
  - Google Cloud SDK support
  - Unified cloud provider authentication

- **Advanced Features**
  - Workspace management
  - State backend configuration helpers
  - Policy-as-code validation (OPA, Sentinel)

- **Enterprise Features**
  - Private registry support
  - Air-gapped environment support
  - Compliance scanning integration
  - SBOM (Software Bill of Materials) generation

- **Extensibility**
  - Plugin system for custom tools
  - Hook system for pre/post installation
  - Custom script execution

## Future Considerations

### Under Evaluation

- **Container Alternatives**
  - Composite action option (without Docker)
  - Native GitHub Actions implementation
  - Support for Windows runners

- **Advanced Integrations**
  - Terraform Cloud/Enterprise integration
  - Azure DevOps integration
  - GitLab CI compatibility

- **Developer Experience**
  - VS Code extension for workflow generation
  - GitHub Codespaces templates
  - Debugging tools and modes

## Community Requests

Have a feature request? Please:
1. Check existing [issues](https://github.com/Action-Foundry/tf-avm-action/issues) and [discussions](https://github.com/Action-Foundry/tf-avm-action/discussions)
2. Open a new [feature request](https://github.com/Action-Foundry/tf-avm-action/issues/new?template=feature_request.md)
3. Participate in discussions and vote on features you'd like to see

## Contributing

Want to help implement these features?
- See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
- Check issues labeled `good first issue` or `help wanted`
- Reach out in [Discussions](https://github.com/Action-Foundry/tf-avm-action/discussions)

## Release Schedule

- **Patch releases** (1.x.y): As needed for bug fixes and security updates
- **Minor releases** (1.x): Quarterly with new features
- **Major releases** (x.0): Annually with breaking changes (if necessary)

## Versioning Policy

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

## Feedback

Your feedback shapes the roadmap! Share your thoughts:
- [GitHub Discussions](https://github.com/Action-Foundry/tf-avm-action/discussions)
- [Feature Requests](https://github.com/Action-Foundry/tf-avm-action/issues/new?template=feature_request.md)
- Community surveys (announced quarterly)

---

*This roadmap is subject to change based on community feedback, priorities, and resources.*

*Last updated: 2025-12-02*
