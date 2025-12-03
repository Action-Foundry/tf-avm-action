#!/bin/bash
# auth-github.sh - GitHub CLI authentication handler
# Handles authentication for GitHub CLI with support for tokens and workflow defaults

# Source common library
# shellcheck source=scripts/lib/common.sh
# shellcheck disable=SC1091
source "$(dirname "$0")/lib/common.sh"

# Input parameters
GH_TOKEN="${1:-}"

log_header "GitHub CLI Authentication"

# Priority order:
# 1. Personal Access Token (if gh_token provided)
# 2. Workflow default token (GITHUB_TOKEN)

# Function to authenticate with token
authenticate_github() {
    local token_source="$1"
    local token="$2"
    
    log_info "Authenticating with ${token_source}..."
    
    # Pass token securely via stdin
    if ! echo "$token" | gh auth login --with-token 2>/dev/null; then
        log_error "Failed to authenticate with ${token_source}"
        log_error "Verify the token is valid and has required permissions"
        return 1
    fi
    
    # Verify authentication was successful
    if ! gh auth status &>/dev/null; then
        log_error "Authentication appeared to succeed but gh auth status failed"
        return 1
    fi
    
    log_info "Successfully authenticated with ${token_source}"
    return 0
}

if [[ -n "$GH_TOKEN" ]]; then
    if ! authenticate_github "provided GitHub token" "$GH_TOKEN"; then
        exit 1
    fi
elif [[ -n "${GITHUB_TOKEN:-}" ]]; then
    if ! authenticate_github "workflow default token (GITHUB_TOKEN)" "$GITHUB_TOKEN"; then
        exit 1
    fi
else
    log_warn "No GitHub authentication credentials provided"
    log_warn "GitHub CLI will not be authenticated"
    log_info "This is OK if you don't need to interact with GitHub API"
    log_info "To authenticate, provide gh_token input or ensure GITHUB_TOKEN is available"
fi

# Verify authentication status
echo ""
log_info "GitHub CLI authentication status:"
gh auth status 2>&1 || log_warn "Not authenticated to GitHub CLI"

echo ""
log_info "GitHub CLI authentication setup complete"
