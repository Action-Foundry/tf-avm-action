#!/bin/bash
# install-azure-cli.sh - Install Azure CLI with version support
# Supports "latest" and specific version numbers

# Determine the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
# shellcheck source=lib/common.sh
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
    python3 -m venv /opt/azure-cli
    
    if [[ "$version" == "latest" ]]; then
        log_info "Installing latest Azure CLI version..."
        /opt/azure-cli/bin/pip install --no-cache-dir --upgrade pip
        /opt/azure-cli/bin/pip install --no-cache-dir azure-cli
    else
        log_info "Installing Azure CLI version ${version}..."
        /opt/azure-cli/bin/pip install --no-cache-dir --upgrade pip
        if ! /opt/azure-cli/bin/pip install --no-cache-dir "azure-cli==${version}"; then
            log_error "Failed to install Azure CLI version ${version}"
            log_error "This version may not exist. Check available versions at:"
            log_error "https://pypi.org/project/azure-cli/#history"
            exit 1
        fi
    fi
    
    # Create symlink in PATH
    ln -sf /opt/azure-cli/bin/az /usr/local/bin/az
    
    # Get the actual installed version
    local installed_version
    installed_version=$(/opt/azure-cli/bin/az version --output json | jq -r '."azure-cli"')
    
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
