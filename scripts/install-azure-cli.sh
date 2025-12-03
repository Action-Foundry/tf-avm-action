#!/bin/bash
# install-azure-cli.sh - Install Azure CLI with version support
# Supports "latest" and specific version numbers

# Determine the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
# shellcheck source=lib/common.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

VERSION="${1:-latest}"

# Resolve "latest" to actual version
resolve_version() {
    local version="$1"
    
    if [[ "$version" == "latest" ]]; then
        log_info "Using latest Azure CLI version from pip..."
        echo "latest"
    else
        # Remove 'v' prefix if present
        normalize_version "$version"
    fi
}

# Install Azure CLI using pip
install_azure_cli() {
    local version="$1"
    
    log_info "Installing Azure CLI..."
    
    # Create virtual environment for Azure CLI to avoid system package conflicts
    if ! python3 -m venv /opt/azure-cli; then
        log_error "Failed to create Python virtual environment for Azure CLI"
        exit 1
    fi
    
    # Verify virtual environment was created
    if [[ ! -d /opt/azure-cli ]] || [[ ! -f /opt/azure-cli/bin/pip ]]; then
        log_error "Virtual environment creation failed - pip not found"
        exit 1
    fi
    
    if [[ "$version" == "latest" ]]; then
        log_info "Installing latest Azure CLI version..."
        if ! /opt/azure-cli/bin/pip install --no-cache-dir --upgrade pip 2>&1 | tee /tmp/pip-upgrade.log; then
            log_error "Failed to upgrade pip in virtual environment"
            exit 1
        fi
        
        if ! /opt/azure-cli/bin/pip install --no-cache-dir azure-cli 2>&1 | tee /tmp/azure-cli-install.log; then
            log_error "Failed to install Azure CLI"
            log_error "Check /tmp/azure-cli-install.log for details"
            exit 1
        fi
    else
        log_info "Installing Azure CLI version ${version}..."
        if ! /opt/azure-cli/bin/pip install --no-cache-dir --upgrade pip 2>&1 | tee /tmp/pip-upgrade.log; then
            log_error "Failed to upgrade pip in virtual environment"
            exit 1
        fi
        
        if ! /opt/azure-cli/bin/pip install --no-cache-dir "azure-cli==${version}" 2>&1 | tee /tmp/azure-cli-install.log; then
            log_error "Failed to install Azure CLI version ${version}"
            log_error "This version may not exist. Check available versions at:"
            log_error "https://pypi.org/project/azure-cli/#history"
            exit 1
        fi
    fi
    
    # Create symlink in PATH
    if ! ln -sf /opt/azure-cli/bin/az /usr/local/bin/az; then
        log_error "Failed to create symlink for Azure CLI"
        exit 1
    fi
    
    # Verify the symlink works
    if [[ ! -x /usr/local/bin/az ]]; then
        log_error "Azure CLI symlink is not executable"
        exit 1
    fi
    
    # Get the actual installed version
    local installed_version
    if ! installed_version=$(/opt/azure-cli/bin/az version --output json 2>/dev/null | jq -r '."azure-cli"' 2>/dev/null); then
        log_error "Failed to determine installed Azure CLI version"
        exit 1
    fi
    
    if [[ -z "$installed_version" ]] || [[ "$installed_version" == "null" ]]; then
        log_error "Could not determine Azure CLI version (received empty or null response)"
        exit 1
    fi
    
    log_info "Azure CLI v${installed_version} installed successfully"
    
    # Output the resolved version
    echo "AZURE_CLI_VERSION_RESOLVED=${installed_version}"
}

# Main execution
main() {
    local version
    version=$(resolve_version "$VERSION")
    
    install_azure_cli "$version"
}

main
