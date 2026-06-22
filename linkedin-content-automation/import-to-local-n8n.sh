#!/bin/bash
# Posts section2-sales-pipeline.json to a local n8n instance via the REST API.
#
# Usage:
#   chmod +x import-to-local-n8n.sh
#   ./import-to-local-n8n.sh
#
# To find your API key: n8n Settings → API → Create API Key

N8N_URL="${N8N_URL:-http://localhost:5678}"
API_KEY="${N8N_API_KEY:-}"
WORKFLOW_FILE="$(dirname "$0")/section2-sales-pipeline.json"

if [ -z "$API_KEY" ]; then
  echo "Enter your n8n API key (Settings → API → Create API Key):"
  read -r API_KEY
fi

if [ ! -f "$WORKFLOW_FILE" ]; then
  echo "Error: $WORKFLOW_FILE not found."
  exit 1
fi

echo "Posting workflow to $N8N_URL ..."

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "$N8N_URL/api/v1/workflows" \
  -H "X-N8N-API-KEY: $API_KEY" \
  -H "Content-Type: application/json" \
  -d @"$WORKFLOW_FILE")

HTTP_BODY=$(echo "$RESPONSE" | head -n -1)
HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
  WORKFLOW_ID=$(echo "$HTTP_BODY" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
  echo "Done! Workflow created with ID: $WORKFLOW_ID"
  echo "Open it at: $N8N_URL/workflow/$WORKFLOW_ID"
else
  echo "Failed (HTTP $HTTP_CODE):"
  echo "$HTTP_BODY"
  exit 1
fi
