#!/bin/bash
# install-gh-cli.sh - Install GitHub CLI with version support
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
        log_info "Resolving latest GitHub CLI version..."
        # Fetch latest version from GitHub Releases API
        local latest
        latest=$(curl -sSf "https://api.github.com/repos/cli/cli/releases/latest" | jq -r '.tag_name')
        
        if [[ -z "$latest" || "$latest" == "null" ]]; then
            log_error "Failed to resolve latest GitHub CLI version"
            exit 1
        fi
        
        # Remove 'v' prefix
        echo "${latest#v}"
    else
        # Remove 'v' prefix if present
        echo "${version#v}"
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
    local temp_dir
    temp_dir=$(mktemp -d)
    
    log_info "Downloading GitHub CLI v${version} for linux/${arch}..."
    
    cd "$temp_dir"
    
    # Download the tarball
    if ! curl -sSfL -o "gh.tar.gz" "$download_url"; then
        log_error "Failed to download GitHub CLI from: $download_url"
        log_error "Version ${version} may not exist. Check available versions at:"
        log_error "https://github.com/cli/cli/releases"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    log_info "Installing GitHub CLI..."
    tar -xzf gh.tar.gz
    mv "gh_${version}_linux_${arch}/bin/gh" /usr/local/bin/
    chmod +x /usr/local/bin/gh
    
    # Cleanup
    cd /
    rm -rf "$temp_dir"
    
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
