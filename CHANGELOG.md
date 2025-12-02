# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- CODE_OF_CONDUCT.md following Contributor Covenant v2.1
- CHANGELOG.md for version tracking
- Enhanced documentation and examples

### Changed
- Pinned Alpine base image to 3.21.0 for consistency with documentation
- Updated Dockerfile to address hadolint warning

### Fixed
- Documentation inconsistency between Dockerfile and README regarding Alpine version

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
