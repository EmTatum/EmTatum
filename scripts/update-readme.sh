#!/bin/bash

# Configuration
README="${README:-README.md}"
GITHUB_USER="${GITHUB_USER:-EmTatum}"

if [[ ! -f "$README" ]]; then
  echo "Error: $README not found" >&2
  exit 1
fi

echo "README is present: $README"

echo "Fetching latest repositories for $GITHUB_USER..."

# Fetch top 5 recently updated public repos
API_URL="https://api.github.com/users/${GITHUB_USER}/repos?sort=updated&per_page=5"

# We use curl to fetch the JSON response
RESPONSE=$(curl -s -H "User-Agent: update-readme-script" "$API_URL")

# Extract the names and urls using jq
REPO_LIST=$(echo "$RESPONSE" | jq -r '.[] | "- [\(.name)](\(.html_url))"')

# Check if we got a valid list
if [[ -z "$REPO_LIST" || "$REPO_LIST" == *"API rate limit exceeded"* || "$REPO_LIST" == *"Not Found"* || "$REPO_LIST" == "null" ]]; then
  echo "Could not fetch repos. Keeping existing README."
else
  # Ensure the markers exist in README.md
  if ! grep -q "<!-- START_LATEST_REPOS -->" "$README"; then
    echo -e "\n### 🚀 Latest Repositories\n<!-- START_LATEST_REPOS -->\n<!-- END_LATEST_REPOS -->" >> "$README"
  fi

  # Replace the content between markers
  awk -v content="$REPO_LIST" '
    /<!-- START_LATEST_REPOS -->/ {
      print "<!-- START_LATEST_REPOS -->"
      print content
      skip=1
      next
    }
    /<!-- END_LATEST_REPOS -->/ {
      print "<!-- END_LATEST_REPOS -->"
      skip=0
      next
    }
    !skip { print }
  ' "$README" > "${README}.tmp" && mv "${README}.tmp" "$README"

  echo "Successfully updated README.md with latest repositories."
fi
