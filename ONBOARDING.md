# Onboarding Guide for Contributors

Welcome to the tf-avm-action project! This guide will help you get started as a contributor to this GitHub Action.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Testing Your Changes](#testing-your-changes)
- [Code Standards](#code-standards)
- [Documentation](#documentation)
- [Submitting Changes](#submitting-changes)
- [Getting Help](#getting-help)

## Prerequisites

Before you begin, ensure you have the following tools installed:

### Required Tools

- **Git** (2.x or later)
- **Docker** (20.x or later)
- **Bash** (4.0 or later)
- **ShellCheck** (for linting shell scripts)
  ```bash
  # macOS
  brew install shellcheck
  
  # Ubuntu/Debian
  apt-get install shellcheck
  
  # Windows (via WSL)
  apt-get install shellcheck
  ```

### Optional but Recommended

- **VS Code** with extensions:
  - ShellCheck
  - Docker
  - YAML
  - Markdown All in One
- **hadolint** (Dockerfile linter)
  ```bash
  # macOS
  brew install hadolint
  
  # Ubuntu/Debian
  wget -O hadolint https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64
  chmod +x hadolint
  sudo mv hadolint /usr/local/bin/
  ```

## Getting Started

### 1. Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/tf-avm-action.git
   cd tf-avm-action
   ```

3. Add the upstream repository:
   ```bash
   git remote add upstream https://github.com/Action-Foundry/tf-avm-action.git
   ```

### 2. Set Up Your Development Environment

1. Verify prerequisites:
   ```bash
   # Check versions
   git --version
   docker --version
   bash --version
   shellcheck --version
   ```

2. Build the Docker image locally:
   ```bash
   docker build -t tf-avm-action:dev .
   ```

3. Test the basic functionality:
   ```bash
   docker run --rm tf-avm-action:dev
   ```

### 3. Explore the Codebase

Take time to understand the project structure:

```bash
# View the main components
ls -la

# Read the documentation
cat README.md
cat CONTRIBUTING.md
cat AVM_MODULES.md

# Explore the scripts
ls -la scripts/
```

## Project Structure

Understanding the project structure is key to effective contributions:

```
tf-avm-action/
├── .github/
│   ├── workflows/
│   │   └── ci.yml              # CI/CD pipeline
│   ├── ISSUE_TEMPLATE/          # Issue templates
│   └── pull_request_template.md # PR template
│
├── scripts/
│   ├── lib/
│   │   └── common.sh           # Shared functions and utilities
│   ├── install-terraform.sh    # Terraform installation
│   ├── install-azure-cli.sh    # Azure CLI installation
│   ├── install-gh-cli.sh       # GitHub CLI installation
│   ├── auth-azure.sh           # Azure authentication
│   ├── auth-github.sh          # GitHub authentication
│   ├── run-terraform-workflow.sh # Standard Terraform workflows
│   └── avm-deploy.sh           # AVM module deployment (NEW)
│
├── tests/
│   ├── run-all-tests.sh        # Test orchestration
│   ├── test-common.sh          # Common library tests
│   └── test-terraform-workflow.sh # Terraform workflow tests
│
├── examples/
│   ├── README.md               # Examples documentation
│   ├── basic-usage.yml         # Simple usage example
│   ├── azure-deployment.yml    # Azure deployment example
│   ├── multi-environment.yml   # Multi-env deployment
│   └── ... (other examples)
│
├── action.yml                  # GitHub Action definition
├── Dockerfile                  # Container image
├── entrypoint.sh              # Main entrypoint script
├── README.md                   # User documentation
├── CONTRIBUTING.md             # Contribution guidelines
├── AVM_MODULES.md             # AVM usage documentation (NEW)
├── ONBOARDING.md              # This file (NEW)
└── LICENSE                     # MIT License
```

### Key Components

#### action.yml
- Defines the GitHub Action interface
- Specifies inputs, outputs, and runtime configuration
- Maps inputs to environment variables

#### entrypoint.sh
- Main entry point for the action
- Orchestrates tool installation and authentication
- Delegates to specialized scripts for workflows

#### scripts/lib/common.sh
- Shared utility functions used across all scripts
- Logging functions: `log_info`, `log_warn`, `log_error`, `log_header`
- Helper functions: `normalize_version`, `detect_arch`, `verify_checksum`

#### scripts/avm-deploy.sh (NEW)
- Handles Azure Verified Modules deployments
- Orchestrates multi-environment deployments
- Generates Terraform configurations dynamically

#### Dockerfile
- Defines the container image
- Based on Alpine Linux for minimal size
- Installs system dependencies

## Development Workflow

### Creating a New Feature

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/my-new-feature
   ```

2. **Make your changes**:
   - Edit the relevant files
   - Follow the code standards (see below)
   - Add tests if applicable

3. **Test your changes**:
   ```bash
   # Lint shell scripts
   shellcheck -x entrypoint.sh scripts/*.sh scripts/lib/*.sh
   
   # Build the image
   docker build -t tf-avm-action:test .
   
   # Run unit tests
   bash tests/run-all-tests.sh
   
   # Test the action
   docker run --rm tf-avm-action:test
   ```

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: add my new feature"
   ```
   
   Use [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation changes
   - `chore:` for maintenance tasks
   - `ci:` for CI/CD changes
   - `test:` for test additions

5. **Push and create a PR**:
   ```bash
   git push origin feature/my-new-feature
   ```
   Then open a Pull Request on GitHub.

### Fixing a Bug

1. **Create a fix branch**:
   ```bash
   git checkout -b fix/issue-description
   ```

2. **Write a failing test** (if applicable):
   ```bash
   # Add a test case in tests/test-*.sh
   ```

3. **Fix the issue**:
   - Make minimal changes to fix the bug
   - Ensure the test now passes

4. **Verify the fix**:
   ```bash
   bash tests/run-all-tests.sh
   ```

5. **Commit and push**:
   ```bash
   git commit -m "fix: resolve issue with X"
   git push origin fix/issue-description
   ```

## Testing Your Changes

### Unit Tests

Run all unit tests:
```bash
cd tests
bash run-all-tests.sh
```

Run specific test suites:
```bash
bash tests/test-common.sh
bash tests/test-terraform-workflow.sh
```

### Manual Testing

#### Test Tool Installation

```bash
docker run --rm \
  -e INPUT_TERRAFORM_VERSION=1.9.3 \
  -e INPUT_AZURE_CLI_VERSION=latest \
  -e INPUT_GH_CLI_VERSION=2.63.1 \
  tf-avm-action:test
```

#### Test AVM Mode (NEW)

Create a test directory structure:
```bash
mkdir -p /tmp/test-avm/terraform/dev
cat > /tmp/test-avm/terraform/dev/resource_groups.tfvars << 'EOF'
resource_groups = {
  rg1 = {
    name     = "rg-test-dev-eastus-001"
    location = "eastus"
    tags = {
      test = "true"
    }
  }
}
EOF
```

Run the action in AVM mode:
```bash
docker run --rm \
  -v /tmp/test-avm:/workspace \
  -e GITHUB_WORKSPACE=/workspace \
  -e INPUT_ENABLE_AVM_MODE=true \
  -e INPUT_AVM_ENVIRONMENTS=dev \
  -e INPUT_TERRAFORM_WORKING_DIR=/workspace/terraform \
  tf-avm-action:test
```

### Integration Tests

Integration tests run automatically in CI when you create a PR. They test:
- Building the Docker image
- Installing tools with various version combinations
- Running workflows end-to-end

You can also run integration tests locally if you have access to Azure:
```bash
# Set up Azure credentials
export ARM_CLIENT_ID="your-client-id"
export ARM_TENANT_ID="your-tenant-id"
export ARM_SUBSCRIPTION_ID="your-subscription-id"

# Run with Azure authentication
docker run --rm \
  -e ARM_CLIENT_ID \
  -e ARM_TENANT_ID \
  -e ARM_SUBSCRIPTION_ID \
  tf-avm-action:test
```

## Code Standards

### Shell Scripts

Follow the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html):

```bash
#!/bin/bash
# Script description

# Enable strict mode
set -euo pipefail

# Source common library
# shellcheck source=scripts/lib/common.sh
source "$(dirname "$0")/lib/common.sh"

# Use descriptive variable names
# UPPERCASE for environment variables and constants
# lowercase for local variables
CONSTANT_VALUE="value"
local_variable="value"

# Use functions for reusable code
my_function() {
    local param="$1"
    
    log_info "Processing: $param"
    
    # Always quote variables
    if [[ "$param" == "expected" ]]; then
        return 0
    fi
    
    return 1
}

# Use common library functions for logging
log_info "This is info"
log_warn "This is a warning"
log_error "This is an error"
log_header "This is a header"
```

### Key Requirements

1. **Use strict mode**: `set -euo pipefail`
2. **Quote variables**: Always use `"$variable"`
3. **Use `[[ ]]`** for conditionals, not `[ ]`
4. **Use functions** for code organization
5. **Add comments** for complex logic
6. **Use common library** functions instead of defining your own
7. **Pass ShellCheck**: All scripts must pass `shellcheck -x`

### Dockerfile

Follow best practices:

```dockerfile
# Use specific versions
FROM alpine:3.21.0

# Minimize layers
RUN apk add --no-cache \
    package1 \
    package2

# Clean up in the same layer
RUN apk add --no-cache temp-package && \
    do-something && \
    apk del temp-package

# Use COPY instead of ADD
COPY script.sh /script.sh

# Set executable permissions
RUN chmod +x /script.sh
```

### action.yml

```yaml
# Use clear, descriptive names
inputs:
  my_input:
    description: 'Clear description of what this input does'
    required: false
    default: 'sensible-default'

# Document outputs
outputs:
  my_output:
    description: 'Clear description of what this output contains'
```

## Documentation

### When to Update Documentation

Update documentation when you:
- Add a new feature
- Change existing behavior
- Add new inputs or outputs
- Fix a bug that affects usage

### Documentation Files

- **README.md**: User-facing documentation, usage examples
- **AVM_MODULES.md**: Detailed AVM usage guide (NEW)
- **CONTRIBUTING.md**: Contribution guidelines
- **ONBOARDING.md**: This file, for new contributors (NEW)
- **examples/**: Working example workflows
- **Code comments**: For complex logic or non-obvious code

### Documentation Standards

- Use clear, concise language
- Include code examples
- Keep examples up-to-date
- Use proper Markdown formatting
- Add links to external resources

## Submitting Changes

### Before Submitting

Checklist before creating a PR:

- [ ] Code passes all tests (`bash tests/run-all-tests.sh`)
- [ ] Code passes linting (`shellcheck -x entrypoint.sh scripts/*.sh`)
- [ ] Documentation is updated
- [ ] Examples are updated (if applicable)
- [ ] Commit messages follow Conventional Commits
- [ ] Branch is up-to-date with `main`:
  ```bash
  git fetch upstream
  git rebase upstream/main
  ```

### Creating a Pull Request

1. **Push your branch**:
   ```bash
   git push origin feature/my-feature
   ```

2. **Open a PR on GitHub**:
   - Use a clear, descriptive title
   - Fill out the PR template completely
   - Reference any related issues
   - Describe what changed and why

3. **Respond to feedback**:
   - Address reviewer comments
   - Push additional commits as needed
   - Re-request review when ready

### After Your PR is Merged

1. **Update your local repository**:
   ```bash
   git checkout main
   git fetch upstream
   git merge upstream/main
   ```

2. **Delete your feature branch**:
   ```bash
   git branch -d feature/my-feature
   git push origin --delete feature/my-feature
   ```

## Getting Help

### Resources

- **Documentation**:
  - [README.md](README.md) - User guide
  - [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
  - [AVM_MODULES.md](AVM_MODULES.md) - AVM usage guide
  - [Examples](examples/) - Working examples

- **Community**:
  - [GitHub Discussions](https://github.com/Action-Foundry/tf-avm-action/discussions) - Ask questions
  - [Issues](https://github.com/Action-Foundry/tf-avm-action/issues) - Report bugs or request features

### Common Questions

**Q: How do I test my changes locally?**

A: Build the Docker image and run it:
```bash
docker build -t tf-avm-action:test .
docker run --rm tf-avm-action:test
```

**Q: My PR failed CI checks. What do I do?**

A: 
1. Check the CI logs to see what failed
2. Fix the issues locally
3. Re-run tests: `bash tests/run-all-tests.sh`
4. Push the fixes

**Q: How do I add a new AVM module type?**

A:
1. Add a new case in `scripts/avm-deploy.sh` > `generate_terraform_config()`
2. Create example tfvars files
3. Update `AVM_MODULES.md` documentation
4. Add tests

**Q: Can I add support for other cloud providers?**

A: The action is focused on Azure, but contributions for other clouds could be considered. Open a discussion first to align on the approach.

### Need More Help?

Don't hesitate to:
- Ask in [Discussions](https://github.com/Action-Foundry/tf-avm-action/discussions)
- Tag maintainers in your PR
- Open a draft PR for early feedback

## Next Steps

Now that you're onboarded:

1. **Pick an issue**: Look for `good first issue` or `help wanted` labels
2. **Read the code**: Understand how existing features work
3. **Start small**: Begin with documentation or minor bug fixes
4. **Ask questions**: Use Discussions if you're unsure about anything

Welcome to the team! We're excited to have you contributing to tf-avm-action. 🎉

---

*Last updated: 2025-12-02*
