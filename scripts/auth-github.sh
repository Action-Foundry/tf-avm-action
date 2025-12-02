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

if [[ -n "$GH_TOKEN" ]]; then
    log_info "Authenticating with provided GitHub token"
    echo "$GH_TOKEN" | gh auth login --with-token
    
    if gh auth status &>/dev/null; then
        log_info "Successfully authenticated with provided token"
    else
        log_error "Failed to authenticate with provided token"
        exit 1
    fi
    
elif [[ -n "${GITHUB_TOKEN:-}" ]]; then
    log_info "Authenticating with workflow default token (GITHUB_TOKEN)"
    echo "$GITHUB_TOKEN" | gh auth login --with-token
    
    if gh auth status &>/dev/null; then
        log_info "Successfully authenticated with workflow token"
    else
        log_error "Failed to authenticate with workflow token"
        exit 1
    fi
    
else
    log_warn "No GitHub authentication credentials provided"
    log_warn "GitHub CLI will not be authenticated"
    log_info "This is OK if you don't need to interact with GitHub API"
fi

# Verify authentication status
echo ""
log_info "GitHub CLI authentication status:"
gh auth status 2>&1 || log_warn "Not authenticated to GitHub CLI"

echo ""
log_info "GitHub CLI authentication setup complete"
