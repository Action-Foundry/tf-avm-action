# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- CODE_OF_CONDUCT.md following Contributor Covenant v2.1
- CHANGELOG.md for version tracking
- COMPATIBILITY.md with tool version compatibility matrix
- METRICS.md with SMART framework compliance and performance goals
- ROADMAP.md outlining future development plans
- QUALITY_REVIEW.md comprehensive quality assessment report
- CODE_REVIEW.md - December 2025 comprehensive review confirming excellence
- Examples directory with 7 real-world workflow scenarios:
  - Basic usage example
  - Pinned versions for production
  - Complete Azure deployment workflow
  - OIDC authentication example
  - Multi-environment deployment
  - Pull request plan workflow
  - Scheduled drift detection
- Unit testing framework (tests/test-common.sh) with 8 tests
- Test runner script (tests/run-all-tests.sh)
- Unit tests integrated into CI pipeline
- Performance timing metrics (overall and per-tool)
- SHA256 checksum verification for GitHub CLI downloads
- Input validation to prevent injection attacks
- **🆕 Azure Verified Modules (AVM) Support**:
  - `enable_avm_mode` input to enable AVM deployments
  - `avm_environments` input for selecting deployment environments
  - `avm_resource_types` input for selecting resource types to deploy
  - `avm_location` input for default Azure location
  - `avm_environments_deployed` output for deployment status
  - AVM deployment orchestration script (scripts/avm-deploy.sh)
  - Support for resource groups, VNets, and storage accounts
  - Multi-environment deployment (dev, test, uat, staging, prod)
  - Tfvars-driven configuration approach
  - Auto-generation of Terraform configurations from user tfvars
  - Azure CAF naming convention compliance
  - Azure CAF tagging standards implementation
  - AVM_MODULES.md comprehensive documentation
  - ONBOARDING.md for new contributors
  - Example AVM workflow files (single-env, multi-env, matrix)
  - Example tfvars files for dev and prod environments
  - Unit tests for AVM deployment functionality (7 tests)

### Changed
- Pinned Alpine base image to 3.21.0 for consistency with documentation
- Updated Dockerfile with hadolint ignore directive (justified)
- Enhanced README with links to new documentation
- Improved input validation to support build metadata (+ character)
- Made checksum download timeout consistent across scripts
- Added per-tool installation duration logging

### Fixed
- Documentation inconsistency between Dockerfile and README regarding Alpine version
- Input validation regex to support version strings with build metadata
- Large plan output handling in PR workflow example

### Security
- 100% checksum verification for all tool downloads
- Comprehensive input validation
- CodeQL security scan passed with 0 vulnerabilities

## [1.0.0] - Initial Release

### Added
- Docker-based GitHub Action with Terraform, Azure CLI, and GitHub CLI
- Support for version pinning or "latest" for all tools
- Multi-architecture support (amd64 and arm64)
- Comprehensive documentation and security guidelines
- CI/CD pipeline with linting and integration tests
- Checksum verification for Terraform downloads
- Action outputs for resolved tool versions

### Security
- Built on Alpine Linux for minimal attack surface
- SHA256 checksum verification for Terraform
- Package integrity verification for Azure CLI via pip
- Non-root user execution
- Regular dependency updates via Dependabot

[Unreleased]: https://github.com/Action-Foundry/tf-avm-action/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/Action-Foundry/tf-avm-action/releases/tag/v1.0.0
