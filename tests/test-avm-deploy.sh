#!/bin/bash
# test-avm-deploy.sh - Unit tests for AVM deployment script

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "========================================="
echo "Running AVM Deployment Tests"
echo "========================================="
echo ""

# Test helper functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local test_name="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo "  File not found: $file"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_executable() {
    local file="$1"
    local test_name="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [[ -x "$file" ]]; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo "  File is not executable: $file"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_exit_code() {
    local expected_code="$1"
    local actual_code="$2"
    local test_name="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [[ "$expected_code" -eq "$actual_code" ]]; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo "  Expected exit code: $expected_code"
        echo "  Actual exit code:   $actual_code"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Test: Script file exists
echo "Testing script files..."
assert_file_exists "${PROJECT_ROOT}/scripts/avm-deploy.sh" "avm-deploy.sh exists"

# Test: Script is executable
echo ""
echo "Testing script permissions..."
assert_executable "${PROJECT_ROOT}/scripts/avm-deploy.sh" "avm-deploy.sh is executable"

# Test: AVM mode disabled by default
echo ""
echo "Testing AVM deployment with disabled mode..."
set +e
output=$("${PROJECT_ROOT}/scripts/avm-deploy.sh" "false" "" "" "" "." "" "" 2>&1)
exit_code=$?
set -e
assert_exit_code 0 $exit_code "AVM deployment with disabled mode exits successfully"

# Test: AVM mode enabled but no environments specified
echo ""
echo "Testing AVM deployment with no environments..."
set +e
output=$("${PROJECT_ROOT}/scripts/avm-deploy.sh" "true" "" "" "" "." "" "" 2>&1)
exit_code=$?
set -e
assert_exit_code 1 $exit_code "AVM deployment rejects missing environments"

# Test: AVM mode with non-existent working directory
echo ""
echo "Testing AVM deployment with invalid working directory..."
set +e
output=$("${PROJECT_ROOT}/scripts/avm-deploy.sh" "true" "dev" "" "" "/nonexistent/path" "" "" 2>&1)
exit_code=$?
set -e
assert_exit_code 1 $exit_code "AVM deployment rejects non-existent working directory"

# Test: AVM mode with valid parameters but non-existent environment directory
echo ""
echo "Testing AVM deployment with non-existent environment..."
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

set +e
output=$("${PROJECT_ROOT}/scripts/avm-deploy.sh" "true" "dev" "resource_groups" "eastus" "$TEMP_DIR" "" "" 2>&1)
exit_code=$?
set -e
# This should fail because the environment directory doesn't exist
assert_exit_code 1 $exit_code "AVM deployment rejects non-existent environment directory"

# Test: Environment name validation warning
echo ""
echo "Testing environment name validation..."
mkdir -p "$TEMP_DIR/custom-env"
cat > "$TEMP_DIR/custom-env/resource_groups.tfvars" << 'EOF'
resource_groups = {}
EOF

set +e
output=$("${PROJECT_ROOT}/scripts/avm-deploy.sh" "true" "custom-env" "resource_groups" "eastus" "$TEMP_DIR" "" "" 2>&1)
exit_code=$?
set -e
# Check if warning about non-standard environment name appears
if echo "$output" | grep -q "does not match standard names"; then
    echo -e "${GREEN}✓ PASS${NC}: AVM deployment warns about non-standard environment names"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗ FAIL${NC}: AVM deployment should warn about non-standard environment names"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

# Print summary
echo ""
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
