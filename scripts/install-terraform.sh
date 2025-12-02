#!/bin/bash
# install-terraform.sh - Install Terraform with version support
# Supports "latest" and specific version numbers

set -euo pipefail

VERSION="${1:-latest}"
ARCH="${2:-amd64}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Resolve "latest" to actual version
resolve_version() {
    local version="$1"
    
    if [[ "$version" == "latest" ]]; then
        log_info "Resolving latest Terraform version..."
        # Fetch latest version from HashiCorp releases API
        local latest
        latest=$(curl -sSf --max-time 30 "https://api.releases.hashicorp.com/v1/releases/terraform/latest" | jq -r '.version')
        
        if [[ -z "$latest" || "$latest" == "null" ]]; then
            log_error "Failed to resolve latest Terraform version"
            exit 1
        fi
        
        echo "$latest"
    else
        # Remove 'v' prefix if present
        echo "${version#v}"
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
    temp_dir=$(mktemp -d)
    
    log_info "Downloading Terraform v${version} for linux/${arch}..."
    
    cd "$temp_dir"
    
    # Download the zip and checksums
    if ! curl -sSfL --max-time 300 -o "terraform.zip" "$download_url"; then
        log_error "Failed to download Terraform from: $download_url"
        log_error "Version ${version} may not exist. Check available versions at:"
        log_error "https://releases.hashicorp.com/terraform/"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    if curl -sSfL --max-time 30 -o "SHA256SUMS" "$checksum_url" 2>/dev/null; then
        log_info "Verifying checksum..."
        # Extract the expected checksum for our file
        expected_checksum=$(grep "terraform_${version}_linux_${arch}.zip" SHA256SUMS | awk '{print $1}')
        actual_checksum=$(sha256sum terraform.zip | awk '{print $1}')
        
        if [[ "$expected_checksum" != "$actual_checksum" ]]; then
            log_error "Checksum verification failed!"
            log_error "Expected: $expected_checksum"
            log_error "Actual:   $actual_checksum"
            rm -rf "$temp_dir"
            exit 1
        fi
        log_info "Checksum verified successfully"
    else
        log_warn "Could not download checksums file, skipping verification"
    fi
    
    log_info "Installing Terraform..."
    unzip -q terraform.zip
    mv terraform /usr/local/bin/
    chmod +x /usr/local/bin/terraform
    
    # Cleanup
    cd /
    rm -rf "$temp_dir"
    
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
