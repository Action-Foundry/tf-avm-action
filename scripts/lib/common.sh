#!/bin/bash
# common.sh - Shared utility functions for tf-avm-action scripts
# This library provides common logging and utility functions used across all installation scripts

# Prevent multiple inclusions
if [[ -n "${_COMMON_SH_LOADED:-}" ]]; then
    return 0
fi
readonly _COMMON_SH_LOADED=1

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Colors for output (only if terminal supports colors)
if [[ -t 1 ]] || [[ "${FORCE_COLOR:-}" == "1" ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly NC='\033[0m' # No Color
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly NC=''
fi

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_debug() {
    if [[ "${DEBUG:-}" == "1" ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $1"
    fi
}

log_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Detect system architecture
# Returns: amd64 or arm64
detect_arch() {
    local arch
    arch=$(uname -m)
    case "$arch" in
        x86_64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        *)
            log_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
}

# Create a temporary directory that is automatically cleaned up on exit
# Returns: Path to the temporary directory
create_temp_dir() {
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Set up trap to clean up on exit (both normal and error)
    # shellcheck disable=SC2064
    trap "rm -rf '$temp_dir'" EXIT
    
    echo "$temp_dir"
}

# Download a file with retry logic
# Arguments:
#   $1 - URL to download
#   $2 - Output file path
#   $3 - Max timeout in seconds (optional, default: 300)
#   $4 - Number of retries (optional, default: 3)
# Returns: 0 on success, 1 on failure
download_file() {
    local url="$1"
    local output="$2"
    local timeout="${3:-300}"
    local retries="${4:-3}"
    local attempt=1
    
    while [[ $attempt -le $retries ]]; do
        log_debug "Download attempt $attempt of $retries: $url"
        if curl -sSfL --max-time "$timeout" -o "$output" "$url" 2>/dev/null; then
            log_debug "Download successful: $output"
            return 0
        fi
        
        if [[ $attempt -lt $retries ]]; then
            log_warn "Download attempt $attempt failed, retrying..."
            sleep $((attempt * 2))  # Exponential backoff
        fi
        ((attempt++))
    done
    
    log_error "Failed to download: $url"
    return 1
}

# Verify SHA256 checksum of a file
# Arguments:
#   $1 - File to verify
#   $2 - Expected checksum
# Returns: 0 on success, 1 on failure
verify_checksum() {
    local file="$1"
    local expected="$2"
    
    local actual
    actual=$(sha256sum "$file" | awk '{print $1}')
    
    if [[ "$expected" != "$actual" ]]; then
        log_error "Checksum verification failed!"
        log_error "Expected: $expected"
        log_error "Actual:   $actual"
        return 1
    fi
    
    log_info "Checksum verified successfully"
    return 0
}

# Normalize version string (remove 'v' prefix if present)
# Arguments:
#   $1 - Version string
# Returns: Normalized version string
normalize_version() {
    echo "${1#v}"
}
