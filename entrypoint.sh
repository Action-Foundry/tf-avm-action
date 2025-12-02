#!/bin/bash
# entrypoint.sh - Main entrypoint for the tf-avm-action
# This script installs the requested tool versions and sets up the environment

# Source common library
# shellcheck source=scripts/lib/common.sh
source /scripts/lib/common.sh

# Input environment variables (set by action.yml)
TERRAFORM_VERSION="${INPUT_TERRAFORM_VERSION:-latest}"
AZURE_CLI_VERSION="${INPUT_AZURE_CLI_VERSION:-latest}"
GH_CLI_VERSION="${INPUT_GH_CLI_VERSION:-latest}"

# Validate inputs (basic sanity checks)
validate_input() {
    local input="$1"
    local name="$2"
    
    # Check for potentially malicious characters
    if [[ "$input" =~ [^a-zA-Z0-9._-] ]]; then
        log_error "Invalid characters in ${name}: ${input}"
        log_error "Only alphanumeric, dots, hyphens, and underscores are allowed"
        exit 1
    fi
    
    # Check for excessively long version strings
    if [[ ${#input} -gt 50 ]]; then
        log_error "${name} is too long (max 50 characters): ${input}"
        exit 1
    fi
}

validate_input "$TERRAFORM_VERSION" "TERRAFORM_VERSION"
validate_input "$AZURE_CLI_VERSION" "AZURE_CLI_VERSION"
validate_input "$GH_CLI_VERSION" "GH_CLI_VERSION"

# Detect architecture
ARCH=$(detect_arch)

log_header "tf-avm-action: Setting up tools"

# Start timing
START_TIME=$(date +%s)

echo ""
log_info "Requested versions:"
log_info "  Terraform:  ${TERRAFORM_VERSION}"
log_info "  Azure CLI:  ${AZURE_CLI_VERSION}"
log_info "  GitHub CLI: ${GH_CLI_VERSION}"
log_info "  Architecture: ${ARCH}"
echo ""

# Variables to store resolved versions
TF_RESOLVED=""
AZ_RESOLVED=""
GH_RESOLVED=""

# Install Terraform
log_header "Installing Terraform"
output=$(/scripts/install-terraform.sh "$TERRAFORM_VERSION" "$ARCH")
echo "$output"
TF_RESOLVED=$(echo "$output" | grep "TERRAFORM_VERSION_RESOLVED=" | cut -d'=' -f2)

# Install Azure CLI
log_header "Installing Azure CLI"
output=$(/scripts/install-azure-cli.sh "$AZURE_CLI_VERSION")
echo "$output"
AZ_RESOLVED=$(echo "$output" | grep "AZURE_CLI_VERSION_RESOLVED=" | cut -d'=' -f2)

# Install GitHub CLI
log_header "Installing GitHub CLI"
output=$(/scripts/install-gh-cli.sh "$GH_CLI_VERSION" "$ARCH")
echo "$output"
GH_RESOLVED=$(echo "$output" | grep "GH_CLI_VERSION_RESOLVED=" | cut -d'=' -f2)

echo ""
log_header "Installation Complete"
log_info "Installed versions:"
log_info "  Terraform:  ${TF_RESOLVED}"
log_info "  Azure CLI:  ${AZ_RESOLVED}"
log_info "  GitHub CLI: ${GH_RESOLVED}"
echo ""

# Verify installations
log_header "Verifying installations"

log_info "Terraform version:"
terraform --version

log_info "Azure CLI version:"
az --version | head -5

log_info "GitHub CLI version:"
gh --version

echo ""

# Set outputs for GitHub Actions
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    log_info "Setting GitHub Action outputs..."
    {
        echo "terraform_version_resolved=${TF_RESOLVED}"
        echo "azure_cli_version_resolved=${AZ_RESOLVED}"
        echo "gh_cli_version_resolved=${GH_RESOLVED}"
    } >> "$GITHUB_OUTPUT"
fi

# Add tools to PATH for subsequent steps (only if not already present)
if [[ -n "${GITHUB_PATH:-}" ]]; then
    if ! echo "$PATH" | grep -q "/usr/local/bin"; then
        echo "/usr/local/bin" >> "$GITHUB_PATH"
    fi
fi

log_header "Setup Complete - Tools are ready!"

# Calculate and display performance metrics
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
echo ""
log_info "⏱️  Setup completed in ${DURATION} seconds"
echo ""

# If additional command arguments are provided, execute them
if [[ $# -gt 0 ]]; then
    log_info "Executing command: $*"
    exec "$@"
fi
