#!/bin/bash
# avm-template-generator.sh - Generic Terraform configuration generator for AVM modules
# This implements a DRY (Don't Repeat Yourself) approach to support all 102 AVM modules

# Source the modules registry
# shellcheck source=scripts/lib/avm-modules-registry.sh
# shellcheck disable=SC1091
# Note: This script is sourced by avm-deploy.sh which already sources the registry
# So we only need to source it if it hasn't been loaded yet
if ! declare -f get_avm_module_source > /dev/null 2>&1; then
    source "$(dirname "${BASH_SOURCE[0]}")/avm-modules-registry.sh"
fi

# Function to generate a generic Terraform configuration for any AVM module
# This uses a data-driven approach to avoid duplicating code for each module
generate_generic_avm_config() {
    local resource_type="$1"
    local config_file="$2"
    
    # Get the module source from the registry
    local module_source
    if ! module_source=$(get_avm_module_source "$resource_type"); then
        return 1
    fi
    
    # Get display name for comments
    local display_name
    display_name=$(get_avm_module_display_name "$resource_type")
    
    # Normalize resource_type for variable names (replace hyphens and special chars with underscores)
    local var_name="${resource_type//-/_}"
    
    # Determine if resource_group_name should be included
    local rg_line=""
    if [[ "$var_name" != "resource_groups" && "$var_name" != "resources_resourcegroup" ]]; then
        rg_line="  resource_group_name = each.value.resource_group_name"
    else
        rg_line="  # resource_group_name not applicable for this resource type"
    fi
    
    # Generate the Terraform configuration
    cat > "$config_file" << EOF
# ${display_name} using AVM module
# https://registry.terraform.io/modules/${module_source}/latest

variable "${var_name}" {
  description = "Map of ${display_name} resources to create"
  type = map(object({
    name                = string
    location            = optional(string)
    resource_group_name = optional(string)
    tags                = optional(map(string), {})
    # Additional properties can be specified based on the module's input variables
    # Users should refer to the module documentation for available options
    # Note: This generic template uses common AVM module parameters (name, location, resource_group_name)
    # For modules with different parameter requirements, use custom templates in avm-deploy.sh
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

module "${var_name}" {
  source   = "${module_source}"
  version  = "~> 0.1"
  for_each = var.${var_name}

  # Core parameters - most AVM modules follow this pattern
  name     = each.value.name
  location = try(each.value.location, var.default_location)
  
  # Conditionally set resource_group_name if provided
  # Most resources need this, some (like resource groups) don't
${rg_line}

  # Note: This generic template provides a baseline configuration
  # Module-specific parameters should be added to the tfvars file
  # and passed through the module block. Refer to the AVM module documentation.

  tags = merge(
    {
      environment = var.environment
      managed_by  = "terraform"
      module      = "${module_source##*/}"
    },
    each.value.tags
  )
}

output "${var_name}_ids" {
  description = "Map of ${display_name} resource IDs"
  value = {
    for k, resource in module.${var_name} : k => try(resource.resource_id, resource.id, null)
  }
}

output "${var_name}_names" {
  description = "Map of ${display_name} resource names"
  value = {
    for k, resource in module.${var_name} : k => try(resource.name, resource.resource_name, k)
  }
}
EOF

    return 0
}

# Export function for use in other scripts
export -f generate_generic_avm_config
