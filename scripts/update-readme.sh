#!/usr/bin/env bash
set -euo pipefail

README="${1:-README.md}"

if [[ ! -f "$README" ]]; then
  echo "Error: $README not found" >&2
  exit 1
fi

echo "README is present: $README"

# Update logic: Add or update a "Last updated" timestamp
DATE_STR=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

TMP_FILE=$(mktemp)

# Use awk to process the file in a single pass.
# It replaces the line starting with "Last updated:" if found,
# otherwise it appends the timestamp at the end.
awk -v date_str="Last updated: $DATE_STR" '
BEGIN { found = 0 }
/^Last updated:/ { print date_str; found = 1; next }
{ print }
END { if (!found) { print ""; print date_str } }
' "$README" > "$TMP_FILE"

# Overwrite the original README with the updated content
mv "$TMP_FILE" "$README"

echo "Updated timestamp in $README"