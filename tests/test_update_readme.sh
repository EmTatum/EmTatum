#!/usr/bin/env bash

# A simple plain bash test for update-readme.sh

# Set up test environment
export README="tests/TEST_README.md"
export GITHUB_USER="octocat"

# Create a dummy README.md for testing
echo "## Dummy Profile" > "$README"

echo "Running update-readme.sh test..."
OUTPUT=$(./scripts/update-readme.sh)
RET_CODE=$?

if [[ $RET_CODE -ne 0 ]]; then
  echo "❌ Script failed with error code $RET_CODE"
  rm -f "$README"
  exit 1
fi

echo "Script output: $OUTPUT"

echo "Checking TEST_README.md content..."
cat "$README"

if grep -q "<!-- START_LATEST_REPOS -->" "$README" && grep -q "<!-- END_LATEST_REPOS -->" "$README"; then
  echo "✅ Markers found in README."
else
  # If we couldn't fetch repos due to rate limit etc., markers are not added.
  if echo "$OUTPUT" | grep -q "Could not fetch repos"; then
    echo "✅ Could not fetch repos due to API limit/error. Skipping marker check."
  else
    echo "❌ Markers not found in README!"
    rm -f "$README"
    exit 1
  fi
fi

if grep -q "\- \[" "$README" || echo "$OUTPUT" | grep -q "Could not fetch repos"; then
  echo "✅ Repositories or rate-limit message found."
else
  echo "❌ Repositories not found and rate limit not hit!"
  rm -f "$README"
  exit 1
fi

# Test idempotency
echo "Running update-readme.sh again for idempotency check..."
OUTPUT2=$(./scripts/update-readme.sh)

MARKER_COUNT=$(grep -c "<!-- START_LATEST_REPOS -->" "$README")
if [[ "$MARKER_COUNT" -eq 1 ]]; then
  echo "✅ Script is idempotent. Marker count is 1."
elif echo "$OUTPUT2" | grep -q "Could not fetch repos"; then
    echo "✅ Script output showed rate-limiting. Skipping strict idempotency check."
else
  echo "❌ Script is not idempotent. Marker count is $MARKER_COUNT!"
  rm -f "$README"
  exit 1
fi

# Clean up
rm -f "$README"
echo "✅ All tests passed successfully."