#!/bin/bash
# test-common.sh - Unit tests for common.sh library functions

# Source the common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../scripts/lib/common.sh
source "${SCRIPT_DIR}/../scripts/lib/common.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [[ "$expected" == "$actual" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "✓ PASS: $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "✗ FAIL: $test_name"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        return 1
    fi
}

assert_not_empty() {
    local actual="$1"
    local test_name="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [[ -n "$actual" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "✓ PASS: $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "✗ FAIL: $test_name"
        echo "  Expected non-empty value, got empty string"
        return 1
    fi
}

echo "========================================="
echo "Running Common Library Tests"
echo "========================================="
echo ""

# Test normalize_version function
echo "Testing normalize_version()..."
result=$(normalize_version "v1.2.3")
assert_equals "1.2.3" "$result" "normalize_version removes 'v' prefix"

result=$(normalize_version "1.2.3")
assert_equals "1.2.3" "$result" "normalize_version handles version without prefix"

result=$(normalize_version "v2.0.0-beta1")
assert_equals "2.0.0-beta1" "$result" "normalize_version handles pre-release versions"

echo ""

# Test detect_arch function
echo "Testing detect_arch()..."
result=$(detect_arch)
assert_not_empty "$result" "detect_arch returns non-empty value"

if [[ "$result" == "amd64" || "$result" == "arm64" ]]; then
    echo "✓ PASS: detect_arch returns valid architecture ($result)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ FAIL: detect_arch returns invalid architecture ($result)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

echo ""

# Test create_temp_dir function
echo "Testing create_temp_dir()..."
temp_dir=$(create_temp_dir 2>&1)
if [[ -n "$temp_dir" ]] && echo "$temp_dir" | grep -q "/tmp"; then
    echo "✓ PASS: create_temp_dir returns a temp path"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    # Directory gets cleaned up by trap in the subshell
else
    echo "✗ FAIL: create_temp_dir did not return a valid temp path"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

echo ""

# Test verify_checksum function (with a known test case)
echo "Testing verify_checksum()..."
test_file=$(mktemp)
echo "test content" > "$test_file"
expected_checksum=$(sha256sum "$test_file" | awk '{print $1}')

if verify_checksum "$test_file" "$expected_checksum" 2>/dev/null; then
    echo "✓ PASS: verify_checksum validates correct checksum"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ FAIL: verify_checksum failed on correct checksum"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

# Test with wrong checksum
if ! verify_checksum "$test_file" "wrongchecksum123456" 2>/dev/null; then
    echo "✓ PASS: verify_checksum rejects incorrect checksum"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ FAIL: verify_checksum accepted incorrect checksum"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

rm -f "$test_file"

echo ""
echo "========================================="
echo "Test Summary"
echo "========================================="
echo "Tests run:    $TESTS_RUN"
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo "✓ All tests passed!"
    exit 0
else
    echo "✗ Some tests failed"
    exit 1
fi
