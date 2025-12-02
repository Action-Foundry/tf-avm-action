#!/bin/bash
# avm-deploy.sh - Deploy Azure resources using Azure Verified Modules (AVM)
# This script orchestrates the deployment of Azure resources across multiple environments
# using user-provided tfvars files and AVM modules from the Terraform Registry

# Source common library
# shellcheck source=scripts/lib/common.sh
# shellcheck disable=SC1091
source "$(dirname "$0")/lib/common.sh"

# Source AVM modules registry
# shellcheck source=scripts/lib/avm-modules-registry.sh
# shellcheck disable=SC1091
source "$(dirname "$0")/lib/avm-modules-registry.sh"

# Source AVM template generator
# shellcheck source=scripts/lib/avm-template-generator.sh
# shellcheck disable=SC1091
source "$(dirname "$0")/lib/avm-template-generator.sh"

# Input parameters
ENABLE_AVM_MODE="${1:-false}"
AVM_ENVIRONMENTS="${2:-}"
AVM_RESOURCE_TYPES="${3:-resource_groups,vnets,storage_accounts}"
AVM_LOCATION="${4:-eastus}"
TERRAFORM_WORKING_DIR="${5:-.}"
TERRAFORM_BACKEND_CONFIG="${6:-}"
TERRAFORM_EXTRA_ARGS="${7:-}"

# Exit if AVM mode is not enabled
if [[ "$ENABLE_AVM_MODE" != "true" ]]; then
    log_info "AVM mode is not enabled, skipping AVM deployment"
    exit 0
fi

# Validate required inputs
if [[ -z "$AVM_ENVIRONMENTS" ]]; then
    log_error "AVM environments not specified. Please provide avm_environments input"
    log_error "Example: avm_environments: 'dev' or 'dev,test,prod'"
    exit 1
fi

log_header "Azure Verified Modules (AVM) Deployment"
log_info "Environments: $AVM_ENVIRONMENTS"
log_info "Resource Types: $AVM_RESOURCE_TYPES"
log_info "Default Location: $AVM_LOCATION"
log_info "Working Directory: $TERRAFORM_WORKING_DIR"
echo ""

# Change to working directory
ORIGINAL_DIR=$(pwd)
if [[ ! -d "$TERRAFORM_WORKING_DIR" ]]; then
    log_error "Terraform working directory does not exist: $TERRAFORM_WORKING_DIR"
    exit 1
fi

cd "$TERRAFORM_WORKING_DIR" || exit 1

# Split environments into array
IFS=',' read -ra ENVIRONMENTS <<< "$AVM_ENVIRONMENTS"

# Split resource types into array
IFS=',' read -ra RESOURCE_TYPES <<< "$AVM_RESOURCE_TYPES"

# Track deployed environments for output
DEPLOYED_ENVIRONMENTS=()

# Function to generate Terraform configuration for a resource type
# This function now supports all 102 AVM modules using a data-driven approach
generate_terraform_config() {
    local resource_type="$1"
    local config_file="$2"
    
    log_info "Generating Terraform configuration for: $resource_type"
    
    # Check if this module is supported in the registry
    if ! get_avm_module_source "$resource_type" > /dev/null 2>&1; then
        log_error "Unsupported resource type: $resource_type"
        log_error "Please check the AVM modules registry or update to use a supported module name"
        return 1
    fi
    
    # For modules with special handling requirements, use custom templates
    # Otherwise, use the generic template generator
    case "$resource_type" in
        resource_groups|resources_resourcegroup)
            # Custom template for resource groups (no resource_group_name needed)
            cat > "$config_file" << 'EOF'
# Resource Groups using AVM module
# https://registry.terraform.io/modules/Azure/avm-res-resources-resourcegroup/azurerm/latest

variable "resource_groups" {
  description = "Map of resource groups to create"
  type = map(object({
    name     = string
    location = optional(string)
    tags     = optional(map(string), {})
  }))
  default = {}
}

variable "default_location" {
  description = "Default location for resources if not specified"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, test, uat, staging, prod)"
  type        = string
}

module "resource_groups" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "~> 0.1"
  for_each = var.resource_groups

  name     = each.value.name
  location = coalesce(each.value.location, var.default_location)
  tags = merge(
    {
      environment = var.environment
      managed_by  = "terraform"
      module      = "avm-res-resources-resourcegroup"
    },
    each.value.tags
  )
}

output "resource_group_ids" {
  description = "Map of resource group IDs"
  value = {
    for k, rg in module.resource_groups : k => try(rg.resource_id, rg.id)
  }
}

output "resource_group_names" {
  description = "Map of resource group names"
  value = {
    for k, rg in module.resource_groups : k => rg.name
  }
}
EOF
            ;;
            
        vnets|network_virtualnetwork)
            # Custom template for VNets with subnets support
            cat > "$config_file" << 'EOF'
# Virtual Networks using AVM module
# https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest

variable "vnets" {
  description = "Map of virtual networks to create"
  type = map(object({
    name                = string
    location            = optional(string)
    resource_group_name = string
    address_space       = list(string)
    subnets = optional(map(object({
      name             = string
      address_prefixes = list(string)
    })), {})
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "default_location" {
  description = "Default location for resources if not specified"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, test, uat, staging, prod)"
  type        = string
}

module "vnets" {
  source   = "Azure/avm-res-network-virtualnetwork/azurerm"
  version  = "~> 0.1"
  for_each = var.vnets

  name                = each.value.name
  location            = coalesce(each.value.location, var.default_location)
  resource_group_name = each.value.resource_group_name
  address_space       = each.value.address_space

  subnets = {
    for subnet_key, subnet in each.value.subnets : subnet_key => {
      name             = subnet.name
      address_prefixes = subnet.address_prefixes
    }
  }

  tags = merge(
    {
      environment = var.environment
      managed_by  = "terraform"
      module      = "avm-res-network-virtualnetwork"
    },
    each.value.tags
  )
}

output "vnet_ids" {
  description = "Map of virtual network IDs"
  value = {
    for k, vnet in module.vnets : k => try(vnet.resource_id, vnet.id)
  }
}

output "vnet_names" {
  description = "Map of virtual network names"
  value = {
    for k, vnet in module.vnets : k => vnet.name
  }
}
EOF
            ;;
            
        storage_accounts|storage_storageaccount)
            # Custom template for storage accounts with specific properties
            cat > "$config_file" << 'EOF'
# Storage Accounts using AVM module
# https://registry.terraform.io/modules/Azure/avm-res-storage-storageaccount/azurerm/latest

variable "storage_accounts" {
  description = "Map of storage accounts to create"
  type = map(object({
    name                     = string
    location                 = optional(string)
    resource_group_name      = string
    account_tier             = optional(string, "Standard")
    account_replication_type = optional(string, "LRS")
    account_kind             = optional(string, "StorageV2")
    tags                     = optional(map(string), {})
  }))
  default = {}
}

variable "default_location" {
  description = "Default location for resources if not specified"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, test, uat, staging, prod)"
  type        = string
}

module "storage_accounts" {
  source   = "Azure/avm-res-storage-storageaccount/azurerm"
  version  = "~> 0.1"
  for_each = var.storage_accounts

  name                     = each.value.name
  location                 = coalesce(each.value.location, var.default_location)
  resource_group_name      = each.value.resource_group_name
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type
  account_kind             = each.value.account_kind

  tags = merge(
    {
      environment = var.environment
      managed_by  = "terraform"
      module      = "avm-res-storage-storageaccount"
    },
    each.value.tags
  )
}

output "storage_account_ids" {
  description = "Map of storage account IDs"
  value = {
    for k, sa in module.storage_accounts : k => try(sa.resource_id, sa.id)
  }
}

output "storage_account_names" {
  description = "Map of storage account names"
  value = {
    for k, sa in module.storage_accounts : k => sa.name
  }
}
EOF
            ;;
            
        *)
            # Use generic template generator for all other modules
            # This covers the remaining 99+ AVM modules using a DRY approach
            if ! generate_generic_avm_config "$resource_type" "$config_file"; then
                log_error "Failed to generate configuration for: $resource_type"
                return 1
            fi
            ;;
    esac
    
    return 0
}

# Function to deploy a single environment
deploy_environment() {
    local env="$1"
    
    log_header "Deploying Environment: $env"
    
    # Check if environment directory exists
    if [[ ! -d "$env" ]]; then
        log_error "Environment directory not found: $TERRAFORM_WORKING_DIR/$env"
        log_error "Please create the directory and add tfvars files for your resources"
        return 1
    fi
    
    # Create a deployment directory for this environment
    local deploy_dir="avm-deploy-${env}"
    mkdir -p "$deploy_dir"
    cd "$deploy_dir" || return 1
    
    log_info "Deployment directory: $(pwd)"
    
    # Generate provider configuration
    log_info "Generating provider configuration..."
    cat > provider.tf << 'EOF'
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
EOF
    
    # Process each resource type
    for resource_type in "${RESOURCE_TYPES[@]}"; do
        # Trim whitespace
        resource_type=$(echo "$resource_type" | xargs)
        
        local tfvars_file="../${env}/${resource_type}.tfvars"
        
        # Check if tfvars file exists
        if [[ ! -f "$tfvars_file" ]]; then
            log_warn "Skipping $resource_type: tfvars file not found at $tfvars_file"
            continue
        fi
        
        log_info "Processing resource type: $resource_type"
        log_info "Using tfvars file: $tfvars_file"
        
        # Generate Terraform configuration for this resource type
        local config_file="${resource_type}.tf"
        if ! generate_terraform_config "$resource_type" "$config_file"; then
            log_error "Failed to generate configuration for $resource_type"
            cd ..
            return 1
        fi
    done
    
    # Build backend config arguments if provided
    BACKEND_CONFIG_ARGS=""
    if [[ -n "$TERRAFORM_BACKEND_CONFIG" ]]; then
        log_info "Configuring backend..."
        while IFS= read -r config; do
            if [[ -n "$config" ]]; then
                BACKEND_CONFIG_ARGS="$BACKEND_CONFIG_ARGS -backend-config=$config"
            fi
        done < <(echo "$TERRAFORM_BACKEND_CONFIG" | tr ' ' '\n')
        
        # Add environment-specific backend key
        BACKEND_CONFIG_ARGS="$BACKEND_CONFIG_ARGS -backend-config=key=avm-${env}.tfstate"
    fi
    
    # Initialize Terraform
    log_header "Terraform Init - $env"
    # shellcheck disable=SC2086
    if ! terraform init $BACKEND_CONFIG_ARGS; then
        log_error "Terraform init failed for environment: $env"
        cd ..
        return 1
    fi
    
    echo ""
    
    # Validate configuration
    log_header "Terraform Validate - $env"
    if ! terraform validate; then
        log_error "Terraform validate failed for environment: $env"
        cd ..
        return 1
    fi
    
    echo ""
    
    # Build variable arguments
    VAR_ARGS=""
    for resource_type in "${RESOURCE_TYPES[@]}"; do
        resource_type=$(echo "$resource_type" | xargs)
        local tfvars_file="../${env}/${resource_type}.tfvars"
        
        if [[ -f "$tfvars_file" ]]; then
            VAR_ARGS="$VAR_ARGS -var-file=$tfvars_file"
        fi
    done
    
    # Add environment and location variables
    VAR_ARGS="$VAR_ARGS -var=environment=$env -var=default_location=$AVM_LOCATION"
    
    # Plan
    log_header "Terraform Plan - $env"
    # shellcheck disable=SC2086
    if ! terraform plan -out=tfplan -input=false $VAR_ARGS $TERRAFORM_EXTRA_ARGS; then
        log_error "Terraform plan failed for environment: $env"
        cd ..
        return 1
    fi
    
    echo ""
    
    # Apply
    log_header "Terraform Apply - $env"
    log_info "Applying changes for environment: $env"
    # shellcheck disable=SC2086
    if ! terraform apply -auto-approve tfplan $TERRAFORM_EXTRA_ARGS; then
        log_error "Terraform apply failed for environment: $env"
        cd ..
        return 1
    fi
    
    echo ""
    
    # Output results
    log_info "Retrieving outputs for environment: $env"
    terraform output -json > "outputs-${env}.json" || true
    
    # Go back to working directory
    cd ..
    
    log_info "✓ Successfully deployed environment: $env"
    return 0
}

# Main deployment loop
DEPLOYMENT_FAILED=false

for env in "${ENVIRONMENTS[@]}"; do
    # Trim whitespace
    env=$(echo "$env" | xargs)
    
    # Validate environment name
    if [[ ! "$env" =~ ^(dev|test|uat|staging|prod)$ ]]; then
        log_warn "Environment name '$env' does not match standard names (dev, test, uat, staging, prod)"
        log_warn "Proceeding anyway, but consider using standard environment names for CAF compliance"
    fi
    
    if deploy_environment "$env"; then
        DEPLOYED_ENVIRONMENTS+=("$env")
    else
        log_error "Failed to deploy environment: $env"
        DEPLOYMENT_FAILED=true
        # Continue with other environments instead of failing completely
    fi
    
    echo ""
done

# Change back to original directory
cd "$ORIGINAL_DIR" || exit 1

# Set output for successfully deployed environments
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    deployed_list=$(IFS=','; echo "${DEPLOYED_ENVIRONMENTS[*]}")
    echo "avm_environments_deployed=${deployed_list}" >> "$GITHUB_OUTPUT"
fi

# Report results
log_header "AVM Deployment Summary"
if [[ ${#DEPLOYED_ENVIRONMENTS[@]} -gt 0 ]]; then
    log_info "Successfully deployed environments: ${DEPLOYED_ENVIRONMENTS[*]}"
else
    log_warn "No environments were successfully deployed"
fi

if [[ "$DEPLOYMENT_FAILED" == "true" ]]; then
    log_error "Some environments failed to deploy"
    exit 1
fi

log_info "✓ All environments deployed successfully"
