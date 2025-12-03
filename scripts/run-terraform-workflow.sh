#!/bin/bash
# run-terraform-workflow.sh - Orchestrate Terraform workflow commands
# Supports: full (init+plan+apply), plan (init+plan), destroy (init+plan+destroy)

# Source common library
# shellcheck source=scripts/lib/common.sh
# shellcheck disable=SC1091
source "$(dirname "$0")/lib/common.sh"

# Input parameters
TERRAFORM_COMMAND="${1:-none}"
TERRAFORM_WORKING_DIR="${2:-.}"
TERRAFORM_BACKEND_CONFIG="${3:-}"
TERRAFORM_VAR_FILE="${4:-}"
TERRAFORM_EXTRA_ARGS="${5:-}"
ENABLE_DRIFT_DETECTION="${6:-false}"
DRIFT_CREATE_ISSUE="${7:-false}"

# Function to create drift detection issue
# Must be defined before usage
create_drift_issue() {
    local plan_output
    plan_output=$(cat plan-output.txt 2>/dev/null || echo "Plan output not available")
    
    # Limit plan output size to prevent GitHub API issues (max 65536 chars for issue body)
    # This also helps reduce exposure of potentially sensitive data
    local max_plan_length=50000
    if [[ ${#plan_output} -gt $max_plan_length ]]; then
        plan_output="${plan_output:0:$max_plan_length}

... (plan output truncated to prevent exposure of sensitive data)
See full plan in workflow logs: ${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY:-unknown}/actions/runs/${GITHUB_RUN_ID:-unknown}"
    fi
    
    # Check if there's already an open drift detection issue
    local existing_issue
    existing_issue=$(gh issue list --label "drift-detection" --state open --json number --jq '.[0].number' 2>/dev/null || echo "")
    
    local issue_body
    issue_body="## Infrastructure Drift Detected

Automated drift detection found differences between the Terraform configuration and actual infrastructure state.

**Detection Date:** $(date -u +"%Y-%m-%dT%H:%M:%S%z")
**Workflow Run:** ${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY:-unknown}/actions/runs/${GITHUB_RUN_ID:-unknown}
**Working Directory:** $TERRAFORM_WORKING_DIR

### ⚠️ Security Notice

The Terraform plan output below may contain sensitive information. Ensure proper repository access controls are in place.
Consider using Terraform's \`-no-color\` and \`sensitive\` variable markings to protect secrets.

### Plan Output

<details>
<summary>Show Terraform Plan (Click to expand)</summary>

\`\`\`terraform
$plan_output
\`\`\`

</details>

### Action Required

Please review the changes and either:
1. Update the infrastructure to match the configuration
2. Update the configuration to match the infrastructure
3. Apply the Terraform changes if they are expected
"
    
    if [[ -z "$existing_issue" ]]; then
        # Create new issue
        gh issue create \
            --title "Infrastructure Drift Detected - $(date +%Y-%m-%d)" \
            --label "drift-detection,infrastructure" \
            --body "$issue_body" 2>/dev/null || log_warn "Failed to create drift detection issue"
    else
        # Update existing issue
        gh issue comment "$existing_issue" \
            --body "## New Drift Detection - $(date +%Y-%m-%d)

Another drift detection run found continued differences.

**Workflow Run:** ${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY:-unknown}/actions/runs/${GITHUB_RUN_ID:-unknown}" \
            2>/dev/null || log_warn "Failed to update drift detection issue"
    fi
}

# Validate terraform command
if [[ "$TERRAFORM_COMMAND" == "none" ]]; then
    log_info "Terraform command is 'none', skipping Terraform workflow"
    exit 0
fi

if [[ ! "$TERRAFORM_COMMAND" =~ ^(full|plan|destroy)$ ]]; then
    log_error "Invalid terraform_command: $TERRAFORM_COMMAND"
    log_error "Valid options: full, plan, destroy, none"
    log_error "Received: $TERRAFORM_COMMAND"
    exit 1
fi

log_header "Terraform Workflow: $TERRAFORM_COMMAND"

# Validate working directory
if [[ ! -d "$TERRAFORM_WORKING_DIR" ]]; then
    log_error "Terraform working directory does not exist: $TERRAFORM_WORKING_DIR"
    log_error "Please ensure the directory exists before running this workflow"
    exit 1
fi

if [[ ! -r "$TERRAFORM_WORKING_DIR" ]]; then
    log_error "Terraform working directory is not readable: $TERRAFORM_WORKING_DIR"
    exit 1
fi

# Store original directory for cleanup
ORIGINAL_DIR=$(pwd)

# Change to working directory
if ! cd "$TERRAFORM_WORKING_DIR"; then
    log_error "Failed to change to working directory: $TERRAFORM_WORKING_DIR"
    exit 1
fi

log_info "Working directory: $(pwd)"

# Verify we have Terraform files
if ! ls *.tf &>/dev/null && ! ls *.tf.json &>/dev/null; then
    log_warn "No Terraform configuration files (*.tf or *.tf.json) found in working directory"
    log_warn "This may cause Terraform to fail"
fi

# Build backend config arguments
BACKEND_CONFIG_ARGS=""
if [[ -n "$TERRAFORM_BACKEND_CONFIG" ]]; then
    log_info "Backend configuration provided"
    # Split space-separated backend config into multiple -backend-config arguments
    while IFS= read -r config; do
        if [[ -n "$config" ]]; then
            BACKEND_CONFIG_ARGS="$BACKEND_CONFIG_ARGS -backend-config=$config"
        fi
    done < <(echo "$TERRAFORM_BACKEND_CONFIG" | tr ' ' '\n')
fi

# Build var-file arguments
VAR_FILE_ARGS=""
if [[ -n "$TERRAFORM_VAR_FILE" ]]; then
    if [[ -f "$TERRAFORM_VAR_FILE" ]]; then
        if [[ -r "$TERRAFORM_VAR_FILE" ]]; then
            VAR_FILE_ARGS="-var-file=$TERRAFORM_VAR_FILE"
            log_info "Using variables file: $TERRAFORM_VAR_FILE"
        else
            log_error "Variables file is not readable: $TERRAFORM_VAR_FILE"
            exit 1
        fi
    else
        log_error "Variables file not found: $TERRAFORM_VAR_FILE"
        log_error "Please ensure the file exists or remove the terraform_var_file input"
        exit 1
    fi
fi

# Initialize Terraform
log_header "Terraform Init"
# shellcheck disable=SC2086
if terraform init $BACKEND_CONFIG_ARGS $TERRAFORM_EXTRA_ARGS; then
    log_info "Terraform initialization successful"
else
    log_error "Terraform initialization failed"
    exit 1
fi

echo ""

# Validate Terraform configuration
log_header "Terraform Validate"
if terraform validate; then
    log_info "Terraform validation successful"
else
    log_error "Terraform validation failed"
    exit 1
fi

echo ""

# Run Terraform Plan
log_header "Terraform Plan"

PLAN_EXITCODE=0
DRIFT_DETECTED="false"

if [[ "$ENABLE_DRIFT_DETECTION" == "true" ]]; then
    log_info "Drift detection enabled"
    # Use -detailed-exitcode to detect changes
    # Exit code 0 = no changes, 1 = error, 2 = changes detected
    
    # Temporarily disable exit on error for detailed-exitcode handling
    set +e
    # Note: VAR_FILE_ARGS and TERRAFORM_EXTRA_ARGS must NOT be quoted to allow proper word splitting
    # shellcheck disable=SC2086
    terraform plan -detailed-exitcode -input=false ${VAR_FILE_ARGS} ${TERRAFORM_EXTRA_ARGS} | tee plan-output.txt
    PLAN_EXITCODE=${PIPESTATUS[0]}
    set -e  # Re-enable exit on error
    
    if [[ $PLAN_EXITCODE -eq 0 ]]; then
        log_info "No changes detected - infrastructure matches configuration"
    elif [[ $PLAN_EXITCODE -eq 2 ]]; then
        DRIFT_DETECTED="true"
        log_warn "Changes detected - infrastructure drift found!"
        
        # Create GitHub issue if requested
        if [[ "$DRIFT_CREATE_ISSUE" == "true" ]]; then
            if gh auth status &>/dev/null; then
                log_info "Creating GitHub issue for drift detection..."
                create_drift_issue
            else
                log_warn "Cannot create drift issue: GitHub CLI is not authenticated"
                log_warn "Provide gh_token input or ensure GITHUB_TOKEN is available"
            fi
        fi
    else
        log_error "Terraform plan failed with exit code: $PLAN_EXITCODE"
        exit 1
    fi
    
    # Set outputs
    if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
        {
            echo "terraform_plan_exitcode=${PLAN_EXITCODE}"
            echo "drift_detected=${DRIFT_DETECTED}"
        } >> "$GITHUB_OUTPUT"
    fi
    
    # For drift detection mode, we typically don't apply changes
    if [[ "$TERRAFORM_COMMAND" == "plan" ]]; then
        log_info "Drift detection complete"
        cd "$ORIGINAL_DIR" || exit 1
        exit 0
    fi
else
    # Regular plan without detailed exit code
    # Note: VAR_FILE_ARGS and TERRAFORM_EXTRA_ARGS must NOT be quoted to allow proper word splitting
    # shellcheck disable=SC2086
    if terraform plan -out=tfplan -input=false ${VAR_FILE_ARGS} ${TERRAFORM_EXTRA_ARGS}; then
        log_info "Terraform plan successful"
    else
        log_error "Terraform plan failed"
        exit 1
    fi
    
    # Set outputs
    if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
        echo "terraform_plan_exitcode=0" >> "$GITHUB_OUTPUT"
    fi
fi

echo ""

# Execute command-specific actions
case "$TERRAFORM_COMMAND" in
    plan)
        log_info "Plan complete - no apply/destroy actions requested"
        ;;
        
    full)
        log_header "Terraform Apply"
        log_info "Applying planned changes..."
        
        # Note: TERRAFORM_EXTRA_ARGS must NOT be quoted to allow proper word splitting
        # shellcheck disable=SC2086
        if terraform apply -auto-approve tfplan ${TERRAFORM_EXTRA_ARGS}; then
            log_info "Terraform apply successful"
        else
            log_error "Terraform apply failed"
            exit 1
        fi
        ;;
        
    destroy)
        log_header "Terraform Destroy"
        log_warn "WARNING: This will destroy all resources managed by this Terraform configuration!"
        log_info "Destroying resources..."
        
        # Note: VAR_FILE_ARGS and TERRAFORM_EXTRA_ARGS must NOT be quoted to allow proper word splitting
        # shellcheck disable=SC2086
        if terraform destroy -auto-approve ${VAR_FILE_ARGS} ${TERRAFORM_EXTRA_ARGS}; then
            log_info "Terraform destroy successful"
        else
            log_error "Terraform destroy failed"
            exit 1
        fi
        ;;
esac

# Change back to original directory
cd "$ORIGINAL_DIR" || exit 1

echo ""
log_header "Terraform Workflow Complete"
log_info "Command: $TERRAFORM_COMMAND"
if [[ "$ENABLE_DRIFT_DETECTION" == "true" ]]; then
    log_info "Drift detected: $DRIFT_DETECTED"
fi
