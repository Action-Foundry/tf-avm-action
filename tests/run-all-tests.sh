#!/bin/bash
# run-all-tests.sh - Run all test suites

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================="
echo "Running All Test Suites"
echo "========================================="
echo ""

# Track overall status
OVERALL_STATUS=0

# Run common library tests
echo "Running common library tests..."
if bash "${SCRIPT_DIR}/test-common.sh"; then
    echo "✓ Common library tests passed"
else
    echo "✗ Common library tests failed"
    OVERALL_STATUS=1
fi

echo ""

# Run Terraform workflow tests
echo "Running Terraform workflow tests..."
if bash "${SCRIPT_DIR}/test-terraform-workflow.sh"; then
    echo "✓ Terraform workflow tests passed"
else
    echo "✗ Terraform workflow tests failed"
    OVERALL_STATUS=1
fi

echo ""

# Run AVM deployment tests
echo "Running AVM deployment tests..."
if bash "${SCRIPT_DIR}/test-avm-deploy.sh"; then
    echo "✓ AVM deployment tests passed"
else
    echo "✗ AVM deployment tests failed"
    OVERALL_STATUS=1
fi

echo ""
echo "========================================="
echo "All Tests Complete"
echo "========================================="

if [[ $OVERALL_STATUS -eq 0 ]]; then
    echo "✓ All test suites passed!"
    exit 0
else
    echo "✗ Some test suites failed"
    exit 1
fi
