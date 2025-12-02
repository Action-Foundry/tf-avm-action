#!/bin/bash
# test-install-scripts.sh - Tests for installation scripts version resolution

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

assert_matches() {
    local pattern="$1"
    local actual="$2"
    local test_name="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [[ "$actual" =~ $pattern ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "✓ PASS: $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "✗ FAIL: $test_name"
        echo "  Pattern: '$pattern'"
        echo "  Actual:  '$actual'"
        return 1
    fi
}

echo "========================================="
echo "Running Installation Scripts Tests"
echo "========================================="
echo ""

# Test that logging doesn't interfere with version capture
echo "Testing version resolution with logging..."

# Mock resolve_version function that includes logging
resolve_version_with_logging() {
    local version="$1"
    
    if [[ "$version" == "latest" ]]; then
        log_info "Resolving latest version..."
        # Mock API response
        echo "1.14.0"
    else
        normalize_version "$version"
    fi
}

# Capture the version (should only get "1.14.0", not the log message)
captured=$(resolve_version_with_logging "latest")
assert_equals "1.14.0" "$captured" "Version capture excludes log messages"

# Test that version matches expected format
assert_matches "^[0-9]+\.[0-9]+\.[0-9]+$" "$captured" "Captured version matches semver format"

echo ""

# Test normalize_version with various inputs
echo "Testing normalize_version edge cases..."

result=$(normalize_version "v1.2.3")
assert_equals "1.2.3" "$result" "normalize_version handles 'v' prefix"

result=$(normalize_version "1.2.3")
assert_equals "1.2.3" "$result" "normalize_version handles no prefix"

result=$(normalize_version "v2.0.0-beta1")
assert_equals "2.0.0-beta1" "$result" "normalize_version handles pre-release with prefix"

result=$(normalize_version "2.0.0-rc1")
assert_equals "2.0.0-rc1" "$result" "normalize_version handles pre-release without prefix"

echo ""

# Test version validation patterns
echo "Testing version validation patterns..."

validate_version_pattern() {
    local version="$1"
    if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$ ]]; then
        return 0
    else
        return 1
    fi
}

# Valid versions
if validate_version_pattern "1.2.3"; then
    echo "✓ PASS: Version pattern accepts valid version (1.2.3)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ FAIL: Version pattern rejects valid version (1.2.3)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

if validate_version_pattern "1.14.0"; then
    echo "✓ PASS: Version pattern accepts valid version (1.14.0)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ FAIL: Version pattern rejects valid version (1.14.0)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

if validate_version_pattern "2.0.0-beta1"; then
    echo "✓ PASS: Version pattern accepts pre-release version"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ FAIL: Version pattern rejects pre-release version"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

# Invalid versions (should fail)
if ! validate_version_pattern "[INFO] Resolving latest version..."; then
    echo "✓ PASS: Version pattern rejects log message"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ FAIL: Version pattern accepts log message"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

if ! validate_version_pattern "latest"; then
    echo "✓ PASS: Version pattern rejects 'latest' keyword"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ FAIL: Version pattern accepts 'latest' keyword"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

if ! validate_version_pattern "v1.2.3"; then
    echo "✓ PASS: Version pattern rejects version with 'v' prefix"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ FAIL: Version pattern accepts version with 'v' prefix"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

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
