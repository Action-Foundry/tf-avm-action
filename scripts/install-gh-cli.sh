#!/bin/bash
# install-gh-cli.sh - Install GitHub CLI with version support
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
        log_info "Resolving latest GitHub CLI version..."
        # Fetch latest version from GitHub Releases API
        local latest
        latest=$(curl -sSf --max-time 30 "https://api.github.com/repos/cli/cli/releases/latest" | jq -r '.tag_name')
        
        if [[ -z "$latest" || "$latest" == "null" ]]; then
            log_error "Failed to resolve latest GitHub CLI version"
            exit 1
        fi
        
        # Remove 'v' prefix
        normalize_version "$latest"
    else
        # Remove 'v' prefix if present
        normalize_version "$version"
    fi
}

# Validate version format
validate_version() {
    local version="$1"
    
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]]; then
        log_error "Invalid GitHub CLI version format: $version"
        log_error "Expected format: X.Y.Z or X.Y.Z-suffix (e.g., 2.63.1)"
        exit 1
    fi
}

# Download and install GitHub CLI
install_gh_cli() {
    local version="$1"
    local arch="$2"
    local download_url="https://github.com/cli/cli/releases/download/v${version}/gh_${version}_linux_${arch}.tar.gz"
    local checksum_url="https://github.com/cli/cli/releases/download/v${version}/gh_${version}_checksums.txt"
    local temp_dir
    temp_dir=$(create_temp_dir)
    
    log_info "Downloading GitHub CLI v${version} for linux/${arch}..."
    
    cd "$temp_dir" || exit 1
    
    # Download the tarball
    if ! download_file "$download_url" "gh.tar.gz" 300; then
        log_error "Version ${version} may not exist. Check available versions at:"
        log_error "https://github.com/cli/cli/releases"
        exit 1
    fi
    
    # Download and verify checksums if available
    local checksum_timeout=300
    if curl -sSfL --max-time "$checksum_timeout" -o "checksums.txt" "$checksum_url" 2>/dev/null; then
        log_info "Verifying checksum..."
        local expected_checksum
        expected_checksum=$(grep "gh_${version}_linux_${arch}.tar.gz" checksums.txt | awk '{print $1}')
        if [[ -n "$expected_checksum" ]]; then
            verify_checksum "gh.tar.gz" "$expected_checksum"
        else
            log_warn "Could not find checksum for this file, skipping verification"
        fi
    else
        log_warn "Could not download checksums file, skipping verification"
    fi
    
    log_info "Installing GitHub CLI..."
    tar -xzf gh.tar.gz
    mv "gh_${version}_linux_${arch}/bin/gh" /usr/local/bin/
    chmod +x /usr/local/bin/gh
    
    # Cleanup is handled by trap set in create_temp_dir
    cd /
    
    log_info "GitHub CLI v${version} installed successfully"
}

# Main execution
main() {
    local version
    version=$(resolve_version "$VERSION")
    
    validate_version "$version"
    install_gh_cli "$version" "$ARCH"
    
    # Output the resolved version
    echo "GH_CLI_VERSION_RESOLVED=${version}"
}

main
