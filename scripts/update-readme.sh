#!/bin/bash
set -euo pipefail

README="${1:-README.md}"

if [[ ! -f "$README" ]]; then
  echo "Error: $README not found" >&2
  exit 1
fi
