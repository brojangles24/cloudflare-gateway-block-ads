#!/bin/bash

# Cloudflare credentials
API_TOKEN="$API_TOKEN"
ACCOUNT_ID="$ACCOUNT_ID"
PREFIX="Block ads"
MAX_RETRIES=10

# Error function
function error() {
    echo "Error: $1"
    exit 1
}

# --- Cleanup local files ---
echo "Cleaning up temporary list files..."
rm -f 1hosts_lite_domains.wildcards.txt 1hosts_lite_domains.wildcards.txt.* 2>/dev/null || true

# --- Get current lists ---
echo "Fetching current Cloudflare DNS lists..."
current_lists=$(curl -sSfL --retry "$MAX_RETRIES" --retry-all-errors \
  -X GET "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/rules/lists" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -H "Content-Type: application/json") || error "Failed to get current lists"

# --- Get current Gateway policies ---
echo "Fetching current Gateway policies..."
current_policies=$(curl -sSfL --retry "$MAX_RETRIES" --retry-all-errors \
  -X GET "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/gateway/rules" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -H "Content-Type: application/json") || error "Failed to get current policies"

# --- Delete matching policy ---
echo "Deleting Gateway policy named '${PREFIX}'..."
policy_id=$(echo "${current_policies}" | jq -r --arg PREFIX "${PREFIX}" \
  '.result | map(select(.name == $PREFIX)) | .[0].id') || error "Failed to parse policy ID"

if [[ -n "${policy_id}" && "${policy_id}" != "null" ]]; then
  curl -sSfL --retry "$MAX_RETRIES" --retry-all-errors \
    -X DELETE "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/gateway/rules/${policy_id}" \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -H "Content-Type: application/json" > /dev/null || error "Failed to delete policy"
  echo "Deleted policy: ${PREFIX}"
else
  echo "No policy named '${PREFIX}' found."
fi

# --- Delete all lists with matching prefix ---
echo "Deleting Cloudflare DNS lists containing prefix '${PREFIX}'..."
for list_id in $(echo "${current_lists}" | jq -r --arg PREFIX "${PREFIX}" \
  '.result | map(select(.name | contains($PREFIX))) | .[].id'); do
    echo "Deleting list ID: ${list_id}"
    curl -sSfL --retry "$MAX_RETRIES" --retry-all-errors \
      -X DELETE "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/rules/lists/${list_id}" \
      -H "Authorization: Bearer ${API_TOKEN}" \
      -H "Content-Type: application/json" > /dev/null || echo "Failed to delete list ${list_id}"
done

echo "✅ Cleanup complete. All matching policies and lists removed."
