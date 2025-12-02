#!/bin/bash
# test-avm-modules-registry.sh - Tests for AVM modules registry

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source the registry
source "${PROJECT_ROOT}/scripts/lib/avm-modules-registry.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "========================================="
echo "Running AVM Modules Registry Tests"
echo "========================================="
echo ""

# Test helper function
test_module_exists() {
    local module_name="$1"
    local test_description="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if get_avm_module_source "$module_name" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}: $test_description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}: $test_description"
        echo "  Module: $module_name not found in registry"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

test_module_display_name() {
    local module_name="$1"
    local test_description="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    local display_name
    if display_name=$(get_avm_module_display_name "$module_name"); then
        if [[ -n "$display_name" && "$display_name" != "$module_name" ]]; then
            echo -e "${GREEN}✓ PASS${NC}: $test_description (Display: $display_name)"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            return 0
        fi
    fi
    
    echo -e "${RED}✗ FAIL${NC}: $test_description"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
}

# Test basic modules (original three)
echo "Testing original modules..."
test_module_exists "resource_groups" "Resource Groups module exists"
test_module_exists "vnets" "VNets module exists"
test_module_exists "storage_accounts" "Storage Accounts module exists"
echo ""

# Test sample of new modules from each category
echo "Testing sample of new modules..."

# API Management
test_module_exists "apimanagement_service" "API Management Service module exists"

# Compute
test_module_exists "compute_virtualmachine" "Virtual Machine module exists"
test_module_exists "compute_virtualmachinescaleset" "VM Scale Set module exists"

# Containers
test_module_exists "containerregistry_registry" "Container Registry module exists"
test_module_exists "containerservice_managedcluster" "AKS module exists"

# Database
test_module_exists "sql_server" "SQL Server module exists"
test_module_exists "dbformysql_flexibleserver" "MySQL module exists"
test_module_exists "documentdb_databaseaccount" "Cosmos DB module exists"

# Networking
test_module_exists "network_applicationgateway" "Application Gateway module exists"
test_module_exists "network_loadbalancer" "Load Balancer module exists"
test_module_exists "network_bastionhost" "Bastion Host module exists"

# Security
test_module_exists "keyvault_vault" "Key Vault module exists"
test_module_exists "managedidentity_userassignedidentity" "Managed Identity module exists"

# Monitoring
test_module_exists "insights_component" "Application Insights module exists"
test_module_exists "operationalinsights_workspace" "Log Analytics module exists"

# Messaging
test_module_exists "eventhub_namespace" "Event Hub module exists"
test_module_exists "servicebus_namespace" "Service Bus module exists"

# Web
test_module_exists "web_site" "Web App module exists"
test_module_exists "web_staticsite" "Static Web App module exists"

echo ""

# Test display names
echo "Testing display names..."
test_module_display_name "keyvault_vault" "Key Vault has display name"
test_module_display_name "compute_virtualmachine" "VM has display name"
test_module_display_name "containerservice_managedcluster" "AKS has display name"
echo ""

# Test invalid module
echo "Testing error handling..."
TESTS_RUN=$((TESTS_RUN + 1))
if ! get_avm_module_source "invalid_module_xyz" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: Invalid module correctly rejected"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗ FAIL${NC}: Invalid module should be rejected"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
echo ""

# Test backwards compatibility aliases
echo "Testing backwards compatibility..."
test_module_exists "resources_resourcegroup" "Resource group alias works"
test_module_exists "storage_storageaccount" "Storage account alias works"
test_module_exists "network_virtualnetwork" "VNet alias works"
echo ""

# Print summary
echo "========================================="
echo "Test Summary"
echo "========================================="
echo "Tests run:    $TESTS_RUN"
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
