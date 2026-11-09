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
    local expected_status="$2"
    shift 2

    echo "Running test: ${name}"
    set +e
    "$@" >/dev/null 2>&1
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
run_test "No args, README.md exists" 0 "${SCRIPT}"

# Test 2: No args, README.md missing
rm README.md
run_test "No args, README.md missing" 1 "${SCRIPT}"

# Test 3: Arg points to existing file
touch custom_readme.txt
run_test "Arg points to existing file" 0 "${SCRIPT}" custom_readme.txt

# Test 4: Arg points to missing file
run_test "Arg points to missing file" 1 "${SCRIPT}" missing_readme.txt

echo "All tests passed successfully!"
