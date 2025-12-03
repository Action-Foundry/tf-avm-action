#!/bin/bash
# common.sh - Shared utility functions for tf-avm-action scripts
# This library provides common logging and utility functions used across all installation scripts
#
# Features:
#   - Colored logging functions (info, warn, error, debug)
#   - Architecture detection (amd64/arm64)
#   - Secure file downloading with retry logic
#   - Checksum verification for security
#   - Temporary directory management
#
# Usage:
#   source "$(dirname "$0")/lib/common.sh"

# Prevent multiple inclusions
if [[ -n "${_COMMON_SH_LOADED:-}" ]]; then
    return 0
fi
readonly _COMMON_SH_LOADED=1

# Exit on error, undefined variables, and pipe failures
# This ensures scripts fail fast on errors rather than continuing with invalid state
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
    echo -e "${GREEN}[INFO]${NC} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_debug() {
    if [[ "${DEBUG:-}" == "1" ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $1" >&2
    fi
}

log_header() {
    echo -e "${BLUE}========================================${NC}" >&2
    echo -e "${BLUE} $1${NC}" >&2
    echo -e "${BLUE}========================================${NC}" >&2
}

# Detect system architecture
# Returns: amd64 or arm64
# Note: This function exits the script on unsupported architecture
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
            log_error "Supported architectures: x86_64 (amd64), aarch64/arm64 (arm64)"
            exit 1
            ;;
    esac
}

# Create a temporary directory
# Returns: Path to the temporary directory
# Note: Caller is responsible for cleanup (or use trap for automatic cleanup)
create_temp_dir() {
    local temp_dir
    
    # Create temp directory with error handling
    if ! temp_dir=$(mktemp -d 2>/dev/null); then
        log_error "Failed to create temporary directory"
        return 1
    fi
    
    # Verify the directory was created and is writable
    if [[ ! -d "$temp_dir" ]] || [[ ! -w "$temp_dir" ]]; then
        log_error "Temporary directory is not accessible: $temp_dir"
        return 1
    fi
    
    log_debug "Created temporary directory: $temp_dir"
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
    
    # Validate inputs
    if [[ -z "$url" ]] || [[ -z "$output" ]]; then
        log_error "download_file: URL and output path are required"
        return 1
    fi
    
    # Validate timeout and retries are positive integers
    if ! [[ "$timeout" =~ ^[0-9]+$ ]] || [[ "$timeout" -lt 1 ]]; then
        log_error "download_file: Invalid timeout value: $timeout"
        return 1
    fi
    
    if ! [[ "$retries" =~ ^[0-9]+$ ]] || [[ "$retries" -lt 1 ]]; then
        log_error "download_file: Invalid retries value: $retries"
        return 1
    fi
    
    while [[ $attempt -le $retries ]]; do
        log_debug "Download attempt $attempt of $retries: $url"
        if curl -sSfL --max-time "$timeout" -o "$output" "$url" 2>/dev/null; then
            log_debug "Download successful: $output"
            # Verify the file was actually created and is not empty
            if [[ -f "$output" ]] && [[ -s "$output" ]]; then
                return 0
            else
                log_warn "Downloaded file is empty or missing: $output"
            fi
        fi
        
        if [[ $attempt -lt $retries ]]; then
            local backoff=$((attempt * 2))
            log_warn "Download attempt $attempt failed, retrying in ${backoff}s..."
            sleep "$backoff"  # Exponential backoff
        fi
        ((attempt++))
    done
    
    log_error "Failed to download after $retries attempts: $url"
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
    
    # Validate inputs
    if [[ -z "$file" ]] || [[ -z "$expected" ]]; then
        log_error "verify_checksum: File path and expected checksum are required"
        return 1
    fi
    
    # Check if file exists and is readable
    if [[ ! -f "$file" ]] || [[ ! -r "$file" ]]; then
        log_error "verify_checksum: File not found or not readable: $file"
        return 1
    fi
    
    # Validate expected checksum format (SHA256 is 64 hex characters)
    if ! [[ "$expected" =~ ^[a-fA-F0-9]{64}$ ]]; then
        log_error "verify_checksum: Invalid SHA256 checksum format: $expected"
        return 1
    fi
    
    local actual
    actual=$(sha256sum "$file" | awk '{print $1}')
    
    # Normalize comparison (convert to lowercase)
    expected=$(echo "$expected" | tr '[:upper:]' '[:lower:]')
    actual=$(echo "$actual" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$expected" != "$actual" ]]; then
        log_error "Checksum verification failed!"
        log_error "Expected: $expected"
        log_error "Actual:   $actual"
        log_error "This may indicate a corrupted download or security issue"
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
