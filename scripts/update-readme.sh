#!/bin/bash
set -euo pipefail

README="${1:-README.md}"

if [[ ! -f "$README" ]]; then
  echo "Error: $README not found" >&2
  exit 1
fi

echo "README is present: $README"

# Update logic: Add or update a "Last updated" timestamp
DATE_STR=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

if grep -q "Last updated:" "$README"; then
  # If it exists, replace the line
  # We use sed to replace the entire line containing "Last updated:"
  sed -i "s/^Last updated: .*/Last updated: $DATE_STR/" "$README"
  echo "Updated timestamp in $README"
else
  # If it doesn't exist, append it
  echo "" >> "$README"
  echo "Last updated: $DATE_STR" >> "$README"
  echo "Appended timestamp to $README"
fi
