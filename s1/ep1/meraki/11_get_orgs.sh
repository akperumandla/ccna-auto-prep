#!/usr/bin/env bash
# Step 1: List every organization your API key can see.
# Grab the "id" of the org you want, then pass it to 12_get_networks.sh.
#
# Required environment variable (export before running):
#   MERAKI_API_KEY   your Meraki Dashboard API key
#
#   export MERAKI_API_KEY="your-api-key-here"

curl -s -w "%{stderr}HTTP Status: %{http_code}\n" \
  -X GET "https://api.meraki.com/api/v1/organizations" \
  -H "Authorization: Bearer $MERAKI_API_KEY" \
  -H "Content-Type: application/json" | jq '.'

# The -w line prints the response code to your screen; the JSON still pipes to jq.
# 200 = OK, 401 = bad/missing API key. See 24_status_codes.sh for the rest.

# jq hints (append after the pipe to trim the output):
#   Name + ID only ......... jq '.[] | {name, id}'
#   Just the IDs ........... jq '.[].id'
#   Find one org by name ... jq '.[] | select(.name=="My Company")'
