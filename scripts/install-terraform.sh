#!/bin/bash
# install-terraform.sh - Install Terraform with version support
# Supports "latest" and specific version numbers

# Determine the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
# shellcheck source=lib/common.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

VERSION="${1:-latest}"
ARCH="${2:-amd64}"

# Resolve "latest" to actual version
resolve_version() {
    local version="$1"
    
    if [[ "$version" == "latest" ]]; then
        log_info "Resolving latest Terraform version..."
        # Fetch latest version from HashiCorp releases API
        local latest
        if ! latest=$(curl -sSf --max-time 30 "https://api.releases.hashicorp.com/v1/releases/terraform/latest" 2>/dev/null | jq -r '.version' 2>/dev/null); then
            log_error "Failed to fetch latest Terraform version from HashiCorp API"
            log_error "Please check your network connection or try specifying a version explicitly"
            exit 1
        fi
        
        if [[ -z "$latest" ]] || [[ "$latest" == "null" ]]; then
            log_error "Failed to resolve latest Terraform version (received invalid response)"
            log_error "This may be due to API changes or network issues"
            exit 1
        fi
        
        log_info "Resolved latest version: $latest"
        echo "$latest"
    else
        # Remove 'v' prefix if present
        normalize_version "$version"
    fi
}

# Validate version format
validate_version() {
    local version="$1"
    
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$ ]]; then
        log_error "Invalid Terraform version format: $version"
        log_error "Expected format: X.Y.Z or X.Y.Z-suffix (e.g., 1.9.3 or 1.9.0-beta1)"
        exit 1
    fi
}

# Download and install Terraform
install_terraform() {
    local version="$1"
    local arch="$2"
    local download_url="https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_${arch}.zip"
    local checksum_url="https://releases.hashicorp.com/terraform/${version}/terraform_${version}_SHA256SUMS"
    local temp_dir
    
    if ! temp_dir=$(create_temp_dir); then
        log_error "Failed to create temporary directory for Terraform installation"
        exit 1
    fi
    
    # Set up cleanup trap for the temporary directory
    # shellcheck disable=SC2064
    trap "rm -rf '$temp_dir'" EXIT
    
    log_info "Downloading Terraform v${version} for linux/${arch}..."
    
    if ! cd "$temp_dir"; then
        log_error "Failed to change to temporary directory: $temp_dir"
        exit 1
    fi
    
    # Download the zip and checksums
    if ! download_file "$download_url" "terraform.zip" 300; then
        log_error "Failed to download Terraform v${version}"
        log_error "Version ${version} may not exist. Check available versions at:"
        log_error "https://releases.hashicorp.com/terraform/"
        exit 1
    fi
    
    # Download and verify checksums (mandatory for security)
    if curl -sSfL --max-time 30 -o "SHA256SUMS" "$checksum_url" 2>/dev/null; then
        log_info "Verifying checksum..."
        # Extract the expected checksum for our file
        local expected_checksum
        expected_checksum=$(grep "terraform_${version}_linux_${arch}.zip" SHA256SUMS | awk '{print $1}')
        
        if [[ -z "$expected_checksum" ]]; then
            log_error "Could not find checksum for terraform_${version}_linux_${arch}.zip in SHA256SUMS file"
            exit 1
        fi
        
        if ! verify_checksum "terraform.zip" "$expected_checksum"; then
            log_error "Checksum verification failed - aborting installation for security"
            exit 1
        fi
    else
        log_error "Could not download checksums file from HashiCorp"
        log_error "Aborting installation for security reasons"
        exit 1
    fi
    
    log_info "Installing Terraform..."
    if ! unzip -q terraform.zip; then
        log_error "Failed to extract Terraform archive"
        exit 1
    fi
    
    if [[ ! -f terraform ]]; then
        log_error "Terraform binary not found in archive"
        exit 1
    fi
    
    if ! mv terraform /usr/local/bin/; then
        log_error "Failed to move Terraform binary to /usr/local/bin/"
        exit 1
    fi
    
    chmod +x /usr/local/bin/terraform
    
    # Verify installation
    if ! /usr/local/bin/terraform version &>/dev/null; then
        log_error "Terraform installation verification failed"
        exit 1
    fi
    
    # Cleanup is handled by trap set above
    cd / || true
    
    log_info "Terraform v${version} installed successfully"
}

# Main execution
main() {
    local version
    version=$(resolve_version "$VERSION")
    
    validate_version "$version"
    install_terraform "$version" "$ARCH"
    
    # Output the resolved version
    echo "TERRAFORM_VERSION_RESOLVED=${version}"
}

main
