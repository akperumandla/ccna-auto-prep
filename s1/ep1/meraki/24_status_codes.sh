#!/usr/bin/env bash
# Step 24: Reading HTTP status codes against the Meraki API.
# Same idea as 04_status_codes.sh, but now with an authenticated API.
#
#   2xx = Success        (it worked)
#   3xx = Redirection    (go look somewhere else)
#   4xx = Client error   (YOU sent something wrong)
#   5xx = Server error   (the API itself broke)
#
# Required environment variable (export before running):
#   MERAKI_API_KEY   your Meraki Dashboard API key
#
#   export MERAKI_API_KEY="your-api-key-here"
#
# IMPORTANT teaching point: Meraki checks your API key FIRST. So if the key is
# wrong, you get 401 no matter what else is in the request. The 4xx example
# below deliberately uses a FAKE key so you can see a 401 without leaking yours.

echo "=== 2xx SUCCESS: a normal call with your REAL key ==="
curl -s -o /dev/null -w "Got: %{http_code}  (200 = OK)\n" \
  -H "Authorization: Bearer $MERAKI_API_KEY" \
  "https://api.meraki.com/api/v1/organizations"

echo "=== 3xx REDIRECT: http:// instead of https:// ==="
# curl won't follow the redirect unless you add -L, so we see the 301 itself.
curl -s -o /dev/null -w "Got: %{http_code}  (301 = Moved Permanently -> use https)\n" \
  -H "Authorization: Bearer $MERAKI_API_KEY" \
  "http://api.meraki.com/api/v1/organizations"

echo "=== 4xx CLIENT ERROR: a fake API key ==="
curl -s -o /dev/null -w "Got: %{http_code}  (401 = Unauthorized, your key is bad or missing)\n" \
  -H "Authorization: Bearer FAKEKEY123" \
  "https://api.meraki.com/api/v1/organizations"

# === 5xx SERVER ERROR ===
# You can't force a 5xx on demand with a fake key (auth is checked first, so you
# only ever get 401). A 500/502/503 means Meraki's own servers had a problem,
# not you. Other 4xx codes you'll meet once you ARE authenticated:
#   400 = Bad Request   (malformed body / invalid parameter value)
#   404 = Not Found     (valid key, but that org/network ID doesn't exist)
#   429 = Too Many Reqs (you hit the rate limit -- back off and retry)
