# Contributing to tf-avm-action

Thank you for your interest in contributing to tf-avm-action! This document provides guidelines and instructions for contributing.

## Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project, you agree to abide by its terms and maintain a welcoming and respectful environment for all contributors.

## How to Contribute

### Reporting Issues

- Search existing issues before creating a new one
- Use the issue templates when available
- Provide clear reproduction steps for bugs
- Include relevant version information (action version, runner OS, tool versions)

### Pull Requests

1. **Fork and Clone**
   ```bash
   git clone https://github.com/YOUR-USERNAME/tf-avm-action.git
   cd tf-avm-action
   ```

2. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

3. **Make Changes**
   - Follow the coding standards below
   - Add tests if applicable
   - Update documentation as needed

4. **Test Locally**
   ```bash
   # Lint shell scripts
   shellcheck -x entrypoint.sh scripts/*.sh scripts/lib/*.sh
   
   # Build Docker image
   docker build -t tf-avm-action:test .
   
   # Test the image
   docker run --rm tf-avm-action:test
   ```

5. **Commit and Push**
   ```bash
   git add .
   git commit -m "feat: add amazing feature"
   git push origin feature/your-feature-name
   ```

6. **Create Pull Request**
   - Use a clear, descriptive title
   - Reference any related issues
   - Describe the changes and their purpose

## Development Setup

### Prerequisites

- Docker
- Bash 4.0+
- ShellCheck (for linting)
- Git

### Project Structure

```
tf-avm-action/
├── .github/
│   ├── workflows/      # CI/CD workflows
│   ├── CODEOWNERS      # Code ownership
│   └── dependabot.yml  # Dependency updates
├── scripts/
│   ├── lib/
│   │   └── common.sh   # Shared utility functions
│   ├── install-terraform.sh
│   ├── install-azure-cli.sh
│   ├── install-gh-cli.sh
│   ├── run-terraform-workflow.sh
│   ├── avm-deploy.sh   # AVM deployment orchestration
│   ├── auth-azure.sh
│   └── auth-github.sh
├── tests/              # Unit tests
│   ├── run-all-tests.sh
│   ├── test-common.sh
│   ├── test-terraform-workflow.sh
│   └── test-avm-deploy.sh
├── examples/           # Example workflows and configs
│   ├── avm-*.yml      # AVM deployment examples
│   └── terraform-configs/  # Example tfvars files
├── action.yml          # GitHub Action definition
├── Dockerfile          # Container image
├── entrypoint.sh       # Main entrypoint script
├── README.md           # User documentation
├── AVM_MODULES.md      # AVM usage guide
├── ONBOARDING.md       # Contributor onboarding
├── CONTRIBUTING.md     # This file
├── SECURITY.md         # Security policy
└── LICENSE             # MIT License
```

## Coding Standards

### Shell Scripts

- Use `#!/bin/bash` shebang
- Enable strict mode: `set -euo pipefail`
- Use the common library functions from `scripts/lib/common.sh`
- Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- All scripts must pass ShellCheck

```bash
# Good
log_info "Installing version ${version}"

# Bad - don't define your own logging functions
echo "[INFO] Installing version ${version}"
```

### Shell Script Best Practices

```bash
# Use local variables in functions
my_function() {
    local my_var="value"
}

# Quote variables
echo "$variable"

# Use lowercase for local variables, UPPERCASE for constants/env vars
readonly MY_CONSTANT="value"
local my_variable="value"

# Use [[ ]] for conditionals
if [[ "$var" == "value" ]]; then
    ...
fi
```

### Dockerfile

- Use specific base image versions
- Minimize layers where possible
- Clean up after package installation
- Add meaningful labels

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add support for custom Terraform providers
fix: resolve version parsing issue for pre-release versions
docs: update README with OIDC authentication example
chore: update Alpine base image to 3.20
ci: add integration test for arm64 architecture
```

Types:
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `chore`: Maintenance tasks
- `ci`: CI/CD changes
- `refactor`: Code refactoring
- `test`: Test additions or modifications

## Testing

### Local Testing

```bash
# Build the Docker image
docker build -t tf-avm-action:test .

# Run with default versions
docker run --rm tf-avm-action:test

# Run with specific versions
docker run --rm \
  -e INPUT_TERRAFORM_VERSION=1.9.3 \
  -e INPUT_AZURE_CLI_VERSION=2.64.0 \
  -e INPUT_GH_CLI_VERSION=2.63.1 \
  tf-avm-action:test
```

### Integration Testing

Integration tests run automatically on pull requests via GitHub Actions. They test:
- Building the Docker image
- Installing tools with `latest` versions
- Installing tools with pinned versions
- Verifying tool functionality

## Release Process

Releases are managed by maintainers:

1. Update version in relevant files
2. Create a GitHub Release with semantic versioning
3. GitHub Actions publishes the release

## Getting Help

- Open a [Discussion](https://github.com/Action-Foundry/tf-avm-action/discussions) for questions
- Check existing [Issues](https://github.com/Action-Foundry/tf-avm-action/issues) for known problems
- Review the [README](README.md) for usage examples
- Check [AVM_MODULES.md](AVM_MODULES.md) for AVM-specific guidance
- Read [ONBOARDING.md](ONBOARDING.md) for detailed contributor guidance

## Recognition

Contributors are recognized in release notes and the repository's contributor list.

Thank you for contributing! 🎉
