#!/usr/bin/env bash
# Step 2: List the networks inside one organization.
# Usage: ./12_get_networks.sh <orgId>
# Grab the network "id" you want, then pass it to 13_get_devices.sh.
#
# Required environment variable (export before running):
#   MERAKI_API_KEY   your Meraki Dashboard API key
#
#   export MERAKI_API_KEY="your-api-key-here"

ORG_ID="$1"

curl -s -w "%{stderr}HTTP Status: %{http_code}\n" \
  -X GET "https://api.meraki.com/api/v1/organizations/${ORG_ID}/networks" \
  -H "Authorization: Bearer $MERAKI_API_KEY" \
  -H "Content-Type: application/json" | jq '.'

# jq hints (append after the pipe to trim the output):
#   Name + ID only ......... jq '.[] | {name, id}'
#   Just the IDs ........... jq '.[].id'
#   Find one network ....... jq '.[] | select(.name=="Main Office")'
