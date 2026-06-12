#!/usr/bin/env bash
# Step 3: List every device in one network.
# Usage: ./13_get_devices.sh <networkId>
#
# Required environment variable (export before running):
#   MERAKI_API_KEY   your Meraki Dashboard API key
#
#   export MERAKI_API_KEY="your-api-key-here"

NETWORK_ID="$1"

curl -s -w "%{stderr}HTTP Status: %{http_code}\n" \
  -X GET "https://api.meraki.com/api/v1/networks/${NETWORK_ID}/devices" \
  -H "Authorization: Bearer $MERAKI_API_KEY" \
  -H "Content-Type: application/json" | jq '.'

# jq hints (append after the pipe to trim the output):
#   Name, model, serial .... jq '.[] | {name, model, serial}'
#   Just the serials ....... jq '.[].serial'
#   Only one model type .... jq '.[] | select(.model=="MR46")'
#   How many devices ....... jq 'length'
