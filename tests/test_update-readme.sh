#!/bin/bash
set -euo pipefail

# Tests for update-readme.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${SCRIPT_DIR}/scripts/update-readme.sh"

TEST_DIR=$(mktemp -d)

echo "Running tests in ${TEST_DIR}"

cleanup() {
    rm -rf "${TEST_DIR}"
}
trap cleanup EXIT

cd "${TEST_DIR}"

run_test() {
    local name="$1"
    local command="$2"
    local expected_status="$3"

    echo "Running test: ${name}"
    set +e
    eval "${command}" >/dev/null 2>&1
    local status=$?
    set -e

    if [[ "${status}" -eq "${expected_status}" ]]; then
        echo "  ✅ Passed"
    else
        echo "  ❌ Failed (Expected status ${expected_status}, got ${status})"
        exit 1
    fi
}


# Test 1: No args, README.md exists
touch README.md
run_test "No args, README.md exists" "${SCRIPT}" 0

# Test 2: No args, README.md missing
rm README.md
run_test "No args, README.md missing" "${SCRIPT}" 1

# Test 3: Arg points to existing file
touch custom_readme.txt
run_test "Arg points to existing file" "${SCRIPT} custom_readme.txt" 0

# Test 4: Arg points to missing file
run_test "Arg points to missing file" "${SCRIPT} missing_readme.txt" 1

echo "All tests passed successfully!"
