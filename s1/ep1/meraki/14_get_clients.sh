#!/usr/bin/env bash
# Step 4: List the clients seen on one network.
# Usage: ./14_get_clients.sh <networkId>
# timespan is in seconds (86400 = last 24 hours, max 2592000 = 31 days).
#
# Required environment variable (export before running):
#   MERAKI_API_KEY   your Meraki Dashboard API key
#
#   export MERAKI_API_KEY="your-api-key-here"

NETWORK_ID="$1"

curl -s -w "%{stderr}HTTP Status: %{http_code}\n" \
  -X GET "https://api.meraki.com/api/v1/networks/${NETWORK_ID}/clients?timespan=86400" \
  -H "Authorization: Bearer $MERAKI_API_KEY" \
  -H "Content-Type: application/json" | jq '.'

# jq hints (append after the pipe to trim the output):
#   Description + MAC + IP . jq '.[] | {description, mac, ip}'
#   Just the MAC addresses . jq '.[].mac'
#   Only wireless clients .. jq '.[] | select(.ssid != null)'
#   How many clients ....... jq 'length'
