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

# Test 5: Verify append behavior when timestamp absent
echo "Running test: Verify append behavior when timestamp absent"
echo "Initial content" > append_readme.txt
eval "${SCRIPT} append_readme.txt" >/dev/null 2>&1
status=$?

if [[ "${status}" -ne 0 ]]; then
    echo "  ❌ Failed (Expected status 0, got ${status})"
    exit 1
fi

last_line=$(tail -n 1 append_readme.txt)
if [[ ! "${last_line}" =~ ^Last\ updated:\ [0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}\ UTC$ ]]; then
    echo "  ❌ Failed (Timestamp not correctly appended. Got: '${last_line}')"
    exit 1
fi

second_last_line=$(tail -n 2 append_readme.txt | head -n 1)
if [[ "${second_last_line}" != "" ]]; then
    echo "  ❌ Failed (Expected blank line before timestamp. Got: '${second_last_line}')"
    exit 1
fi

echo "  ✅ Passed"

# Test 6: Verify update behavior when timestamp is present
echo "Running test: Verify update behavior when timestamp is present"
cat << 'EOF' > update_readme.txt
Some initial content
Last updated: 2020-01-01 00:00:00 UTC
Some trailing content
EOF

eval "${SCRIPT} update_readme.txt" >/dev/null 2>&1
status=$?

if [[ "${status}" -ne 0 ]]; then
    echo "  ❌ Failed (Expected status 0, got ${status})"
    exit 1
fi

updated_line=$(grep "^Last updated:" update_readme.txt)
if [[ ! "${updated_line}" =~ ^Last\ updated:\ [0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}\ UTC$ ]]; then
    echo "  ❌ Failed (Timestamp not correctly updated. Got: '${updated_line}')"
    exit 1
fi

if [[ "${updated_line}" == "Last updated: 2020-01-01 00:00:00 UTC" ]]; then
    echo "  ❌ Failed (Timestamp was not changed from original)"
    exit 1
fi

line_count=$(grep -c "^Last updated:" update_readme.txt)
if [[ "${line_count}" -ne 1 ]]; then
    echo "  ❌ Failed (Expected exactly one timestamp line, got ${line_count})"
    exit 1
fi

echo "  ✅ Passed"

echo "All tests passed successfully!"
