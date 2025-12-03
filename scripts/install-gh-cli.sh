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
        if ! latest=$(curl -sSf --max-time 30 "https://api.github.com/repos/cli/cli/releases/latest" 2>/dev/null | jq -r '.tag_name' 2>/dev/null); then
            log_error "Failed to fetch latest GitHub CLI version from GitHub API"
            log_error "Please check your network connection or try specifying a version explicitly"
            exit 1
        fi
        
        if [[ -z "$latest" ]] || [[ "$latest" == "null" ]] || [[ "$latest" == "null"* ]]; then
            log_error "Failed to resolve latest GitHub CLI version (received invalid response)"
            log_error "This may be due to API rate limiting or network issues"
            exit 1
        fi
        
        log_info "Resolved latest version: $latest"
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
    
    if ! temp_dir=$(create_temp_dir); then
        log_error "Failed to create temporary directory for GitHub CLI installation"
        exit 1
    fi
    
    # Set up cleanup trap for the temporary directory
    # shellcheck disable=SC2064
    trap "rm -rf '$temp_dir'" EXIT
    
    log_info "Downloading GitHub CLI v${version} for linux/${arch}..."
    
    if ! cd "$temp_dir"; then
        log_error "Failed to change to temporary directory: $temp_dir"
        exit 1
    fi
    
    # Download the tarball
    if ! download_file "$download_url" "gh.tar.gz" 300; then
        log_error "Failed to download GitHub CLI v${version}"
        log_error "Version ${version} may not exist. Check available versions at:"
        log_error "https://github.com/cli/cli/releases"
        exit 1
    fi
    
    # Download and verify checksums (strongly recommended for security)
    local checksum_timeout=300
    if curl -sSfL --max-time "$checksum_timeout" -o "checksums.txt" "$checksum_url" 2>/dev/null; then
        log_info "Verifying checksum..."
        local expected_checksum
        expected_checksum=$(grep "gh_${version}_linux_${arch}.tar.gz" checksums.txt | awk '{print $1}')
        
        if [[ -n "$expected_checksum" ]]; then
            if ! verify_checksum "gh.tar.gz" "$expected_checksum"; then
                log_error "Checksum verification failed - aborting installation for security"
                exit 1
            fi
        else
            log_warn "Could not find checksum for this file in checksums.txt"
            log_warn "Proceeding with installation but recommend checking file integrity"
        fi
    else
        log_warn "Could not download checksums file from GitHub"
        log_warn "Proceeding with installation but recommend verifying file integrity"
    fi
    
    log_info "Installing GitHub CLI..."
    if ! tar -xzf gh.tar.gz; then
        log_error "Failed to extract GitHub CLI archive"
        exit 1
    fi
    
    local extracted_dir="gh_${version}_linux_${arch}"
    if [[ ! -d "$extracted_dir" ]] || [[ ! -f "$extracted_dir/bin/gh" ]]; then
        log_error "GitHub CLI binary not found in expected location: $extracted_dir/bin/gh"
        exit 1
    fi
    
    if ! mv "$extracted_dir/bin/gh" /usr/local/bin/; then
        log_error "Failed to move GitHub CLI binary to /usr/local/bin/"
        exit 1
    fi
    
    chmod +x /usr/local/bin/gh
    
    # Verify installation
    if ! /usr/local/bin/gh version &>/dev/null; then
        log_error "GitHub CLI installation verification failed"
        exit 1
    fi
    
    # Cleanup is handled by trap set above
    cd / || true
    
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
