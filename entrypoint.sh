#!/bin/bash
# entrypoint.sh - Main entrypoint for the tf-avm-action
# This script installs the requested tool versions and sets up the environment

# Source common library
# shellcheck source=scripts/lib/common.sh
# shellcheck disable=SC1091
source /scripts/lib/common.sh

# Input environment variables (set by action.yml)
# Tool versions
TERRAFORM_VERSION="${INPUT_TERRAFORM_VERSION:-latest}"
AZURE_CLI_VERSION="${INPUT_AZURE_CLI_VERSION:-latest}"
GH_CLI_VERSION="${INPUT_GH_CLI_VERSION:-latest}"

# Terraform workflow
TERRAFORM_COMMAND="${INPUT_TERRAFORM_COMMAND:-none}"
TERRAFORM_WORKING_DIR="${INPUT_TERRAFORM_WORKING_DIR:-.}"
TERRAFORM_BACKEND_CONFIG="${INPUT_TERRAFORM_BACKEND_CONFIG:-}"
TERRAFORM_VAR_FILE="${INPUT_TERRAFORM_VAR_FILE:-}"
TERRAFORM_EXTRA_ARGS="${INPUT_TERRAFORM_EXTRA_ARGS:-}"

# Drift detection
ENABLE_DRIFT_DETECTION="${INPUT_ENABLE_DRIFT_DETECTION:-false}"
DRIFT_CREATE_ISSUE="${INPUT_DRIFT_CREATE_ISSUE:-false}"

# GitHub CLI authentication
GH_TOKEN="${INPUT_GH_TOKEN:-}"

# Azure authentication
AZURE_CLIENT_ID="${INPUT_AZURE_CLIENT_ID:-}"
AZURE_CLIENT_SECRET="${INPUT_AZURE_CLIENT_SECRET:-}"
AZURE_SUBSCRIPTION_ID="${INPUT_AZURE_SUBSCRIPTION_ID:-}"
AZURE_TENANT_ID="${INPUT_AZURE_TENANT_ID:-}"
AZURE_USE_OIDC="${INPUT_AZURE_USE_OIDC:-false}"

# AVM (Azure Verified Modules) support
ENABLE_AVM_MODE="${INPUT_ENABLE_AVM_MODE:-false}"
AVM_ENVIRONMENTS="${INPUT_AVM_ENVIRONMENTS:-}"
AVM_RESOURCE_TYPES="${INPUT_AVM_RESOURCE_TYPES:-resource_groups,vnets,storage_accounts}"
AVM_LOCATION="${INPUT_AVM_LOCATION:-eastus}"

# Validate inputs (basic sanity checks)
validate_input() {
    local input="$1"
    local name="$2"
    
    # Check for potentially malicious characters
    # Allow alphanumeric, dots, hyphens, underscores, and plus signs (for build metadata)
    if [[ "$input" =~ [^a-zA-Z0-9._+-] ]]; then
        log_error "Invalid characters in ${name}: ${input}"
        log_error "Only alphanumeric, dots, hyphens, underscores, and plus signs are allowed"
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
TF_START=$(date +%s)
output=$(/scripts/install-terraform.sh "$TERRAFORM_VERSION" "$ARCH")
echo "$output"
TF_RESOLVED=$(echo "$output" | grep "TERRAFORM_VERSION_RESOLVED=" | cut -d'=' -f2)
TF_END=$(date +%s)
TF_DURATION=$((TF_END - TF_START))
log_info "Terraform installation took ${TF_DURATION}s"

# Install Azure CLI
log_header "Installing Azure CLI"
AZ_START=$(date +%s)
output=$(/scripts/install-azure-cli.sh "$AZURE_CLI_VERSION")
echo "$output"
AZ_RESOLVED=$(echo "$output" | grep "AZURE_CLI_VERSION_RESOLVED=" | cut -d'=' -f2)
AZ_END=$(date +%s)
AZ_DURATION=$((AZ_END - AZ_START))
log_info "Azure CLI installation took ${AZ_DURATION}s"

# Install GitHub CLI
log_header "Installing GitHub CLI"
GH_START=$(date +%s)
output=$(/scripts/install-gh-cli.sh "$GH_CLI_VERSION" "$ARCH")
echo "$output"
GH_RESOLVED=$(echo "$output" | grep "GH_CLI_VERSION_RESOLVED=" | cut -d'=' -f2)
GH_END=$(date +%s)
GH_DURATION=$((GH_END - GH_START))
log_info "GitHub CLI installation took ${GH_DURATION}s"

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

# GitHub CLI Authentication
if [[ -n "$GH_TOKEN" ]] || [[ -n "${GITHUB_TOKEN:-}" ]]; then
    /scripts/auth-github.sh "$GH_TOKEN"
    echo ""
fi

# Azure Authentication
if [[ -n "$AZURE_CLIENT_ID" ]] || [[ -n "$AZURE_TENANT_ID" ]]; then
    /scripts/auth-azure.sh "$AZURE_CLIENT_ID" "$AZURE_CLIENT_SECRET" "$AZURE_SUBSCRIPTION_ID" "$AZURE_TENANT_ID" "$AZURE_USE_OIDC"
    echo ""
fi

# Convert relative path to absolute path for working directory
if [[ "$TERRAFORM_WORKING_DIR" != /* ]]; then
    if [[ -z "${GITHUB_WORKSPACE:-}" ]]; then
        log_error "GITHUB_WORKSPACE environment variable is not set"
        exit 1
    fi
    TERRAFORM_WORKING_DIR="${GITHUB_WORKSPACE}/${TERRAFORM_WORKING_DIR}"
fi

# Validate the resolved path exists
if [[ ! -d "$TERRAFORM_WORKING_DIR" ]]; then
    log_error "Terraform working directory does not exist: $TERRAFORM_WORKING_DIR"
    exit 1
fi

# Run AVM Deployment (takes priority over standard Terraform workflow)
if [[ "$ENABLE_AVM_MODE" == "true" ]]; then
    /scripts/avm-deploy.sh \
        "$ENABLE_AVM_MODE" \
        "$AVM_ENVIRONMENTS" \
        "$AVM_RESOURCE_TYPES" \
        "$AVM_LOCATION" \
        "$TERRAFORM_WORKING_DIR" \
        "$TERRAFORM_BACKEND_CONFIG" \
        "$TERRAFORM_EXTRA_ARGS"
    echo ""
# Run Standard Terraform Workflow
elif [[ "$TERRAFORM_COMMAND" != "none" ]]; then
    /scripts/run-terraform-workflow.sh \
        "$TERRAFORM_COMMAND" \
        "$TERRAFORM_WORKING_DIR" \
        "$TERRAFORM_BACKEND_CONFIG" \
        "$TERRAFORM_VAR_FILE" \
        "$TERRAFORM_EXTRA_ARGS" \
        "$ENABLE_DRIFT_DETECTION" \
        "$DRIFT_CREATE_ISSUE"
    echo ""
fi

# If additional command arguments are provided, execute them
if [[ $# -gt 0 ]]; then
    log_info "Executing command: $*"
    exec "$@"
fi
