#!/bin/bash

API_TOKEN="$API_TOKEN"
ACCOUNT_ID="$ACCOUNT_ID"
MAX_RETRIES=10

echo "Deleting all existing Cloudflare Gateway lists..."
all_lists=$(curl -sSfL --retry "$MAX_RETRIES" --retry-all-errors -X GET \
  "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/gateway/lists" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -H "Content-Type: application/json") || { echo "Failed to get lists"; exit 1; }

for id in $(echo "$all_lists" | jq -r '.result[].id'); do
    name=$(echo "$all_lists" | jq -r --arg ID "$id" '.result[] | select(.id == $ID) | .name')
    echo "Deleting list: $name ($id)"
    curl -sSfL --retry "$MAX_RETRIES" --retry-all-errors -X DELETE \
      "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/gateway/lists/${id}" \
      -H "Authorization: Bearer ${API_TOKEN}" \
      -H "Content-Type: application/json" > /dev/null || echo "Failed to delete $name"
done

echo "All lists deleted successfully."
