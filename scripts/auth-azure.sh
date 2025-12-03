#!/bin/bash
# auth-azure.sh - Azure authentication handler
# Handles authentication for Azure CLI with support for service principal and OIDC

# Source common library
# shellcheck source=scripts/lib/common.sh
# shellcheck disable=SC1091
source "$(dirname "$0")/lib/common.sh"

# Input parameters
AZURE_CLIENT_ID="${1:-}"
AZURE_CLIENT_SECRET="${2:-}"
AZURE_SUBSCRIPTION_ID="${3:-}"
AZURE_TENANT_ID="${4:-}"
AZURE_USE_OIDC="${5:-false}"

log_header "Azure Authentication"

# Check if Azure authentication is requested
if [[ -z "$AZURE_CLIENT_ID" ]] && [[ -z "$AZURE_SUBSCRIPTION_ID" ]] && [[ -z "$AZURE_TENANT_ID" ]]; then
    log_warn "No Azure credentials provided, skipping Azure authentication"
    log_info "Azure CLI is installed but not authenticated"
    log_info "You can authenticate manually in your workflow steps if needed"
    exit 0
fi

# Validate boolean inputs
if [[ "$AZURE_USE_OIDC" != "true" ]] && [[ "$AZURE_USE_OIDC" != "false" ]]; then
    log_error "Invalid value for AZURE_USE_OIDC: ${AZURE_USE_OIDC}"
    log_error "Must be either 'true' or 'false'"
    exit 1
fi

# Validate required parameters based on auth method
if [[ -z "$AZURE_CLIENT_ID" ]]; then
    log_error "AZURE_CLIENT_ID is required for Azure authentication"
    log_error "Please provide the azure_client_id input parameter"
    exit 1
fi

if [[ -z "$AZURE_TENANT_ID" ]]; then
    log_error "AZURE_TENANT_ID is required for Azure authentication"
    log_error "Please provide the azure_tenant_id input parameter"
    exit 1
fi

if [[ "$AZURE_USE_OIDC" != "true" ]] && [[ -z "$AZURE_CLIENT_SECRET" ]]; then
    log_error "AZURE_CLIENT_SECRET is required for Service Principal authentication"
    log_error "Either provide azure_client_secret or set azure_use_oidc=true"
    exit 1
fi

# Validate UUID format for Azure IDs (basic validation)
if ! [[ "$AZURE_CLIENT_ID" =~ ^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$ ]]; then
    log_warn "AZURE_CLIENT_ID does not match expected UUID format"
    log_warn "Proceeding anyway, but verify your client ID is correct"
fi

if ! [[ "$AZURE_TENANT_ID" =~ ^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$ ]]; then
    log_warn "AZURE_TENANT_ID does not match expected UUID format"
    log_warn "Proceeding anyway, but verify your tenant ID is correct"
fi

if [[ -n "$AZURE_SUBSCRIPTION_ID" ]] && ! [[ "$AZURE_SUBSCRIPTION_ID" =~ ^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$ ]]; then
    log_warn "AZURE_SUBSCRIPTION_ID does not match expected UUID format"
    log_warn "Proceeding anyway, but verify your subscription ID is correct"
fi

# Set environment variables for Terraform Azure provider
export ARM_CLIENT_ID="$AZURE_CLIENT_ID"
export ARM_TENANT_ID="$AZURE_TENANT_ID"

if [[ -n "$AZURE_SUBSCRIPTION_ID" ]]; then
    export ARM_SUBSCRIPTION_ID="$AZURE_SUBSCRIPTION_ID"
fi

# Check authentication method
if [[ "$AZURE_USE_OIDC" == "true" ]]; then
    log_info "Using OIDC authentication for Azure"
    log_info "Note: OIDC authentication requires the azure/login action to be run first"
    log_info "Setting ARM_USE_OIDC=true for Terraform Azure provider"
    export ARM_USE_OIDC=true
    
    # Check if we're in a GitHub Actions environment with OIDC token available
    if [[ -n "${ACTIONS_ID_TOKEN_REQUEST_URL:-}" ]] && [[ -n "${ACTIONS_ID_TOKEN_REQUEST_TOKEN:-}" ]]; then
        log_info "GitHub Actions OIDC token is available"
        
        # Try to verify Azure CLI is authenticated (it should be via azure/login action)
        if az account show &>/dev/null; then
            log_info "Azure CLI is already authenticated (likely via azure/login action)"
            CURRENT_SUB=$(az account show --query id -o tsv 2>/dev/null)
            log_info "Current subscription: $CURRENT_SUB"
        else
            log_warn "Azure CLI is not authenticated yet"
            log_warn "Make sure to run the azure/login action before this step"
        fi
    else
        log_warn "OIDC token environment variables not found"
        log_warn "Make sure permissions.id-token: write is set in your workflow"
    fi
    
else
    log_info "Using Service Principal authentication for Azure"
    
    export ARM_CLIENT_SECRET="$AZURE_CLIENT_SECRET"
    
    # Perform Azure login
    log_info "Logging in to Azure with Service Principal..."
    
    # Use a more secure approach - avoid passing secrets via command line when possible
    # However, az login requires the password via -p flag
    if [[ -n "$AZURE_SUBSCRIPTION_ID" ]]; then
        if ! az login --service-principal \
            -u "$AZURE_CLIENT_ID" \
            -p "$AZURE_CLIENT_SECRET" \
            --tenant "$AZURE_TENANT_ID" \
            --output none 2>&1; then
            log_error "Failed to authenticate to Azure with Service Principal"
            log_error "Exit code: $?"
            # Don't log the full output as it might contain sensitive info
            exit 1
        fi
        
        if ! az account set --subscription "$AZURE_SUBSCRIPTION_ID" --output none 2>&1; then
            log_error "Failed to set Azure subscription to: $AZURE_SUBSCRIPTION_ID"
            log_error "Verify the subscription ID is correct and accessible"
            exit 1
        fi
    else
        if ! az login --service-principal \
            -u "$AZURE_CLIENT_ID" \
            -p "$AZURE_CLIENT_SECRET" \
            --tenant "$AZURE_TENANT_ID" \
            --output none 2>&1; then
            log_error "Failed to authenticate to Azure with Service Principal"
            log_error "Exit code: $?"
            # Don't log the full output as it might contain sensitive info
            exit 1
        fi
    fi
    
    # Verify authentication was successful
    if ! az account show &>/dev/null; then
        log_error "Failed to authenticate to Azure - account show failed"
        log_error "Verify your service principal credentials are correct"
        exit 1
    fi
    
    log_info "Successfully authenticated to Azure"
    
    # Get and display subscription info
    CURRENT_SUB=""
    CURRENT_SUB_NAME=""
    if CURRENT_SUB=$(az account show --query id -o tsv 2>/dev/null); then
        CURRENT_SUB_NAME=$(az account show --query name -o tsv 2>/dev/null)
        log_info "Current subscription: $CURRENT_SUB_NAME ($CURRENT_SUB)"
    else
        log_warn "Could not retrieve subscription information"
    fi
fi

# Export environment variables for subsequent steps
if [[ -n "${GITHUB_ENV:-}" ]]; then
    log_info "Exporting Azure environment variables for workflow steps..."
    {
        echo "ARM_CLIENT_ID=${ARM_CLIENT_ID}"
        echo "ARM_TENANT_ID=${ARM_TENANT_ID}"
        if [[ -n "${ARM_SUBSCRIPTION_ID:-}" ]]; then
            echo "ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID}"
        fi
        if [[ "$AZURE_USE_OIDC" == "true" ]]; then
            echo "ARM_USE_OIDC=true"
        elif [[ -n "${ARM_CLIENT_SECRET:-}" ]]; then
            echo "ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET}"
        fi
    } >> "$GITHUB_ENV"
fi

echo ""
log_info "Azure authentication setup complete"
