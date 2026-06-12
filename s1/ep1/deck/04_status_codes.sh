#!/usr/bin/env bash
# Intro 4: Reading HTTP status codes (the Deck of Cards API, no auth needed).
# Every API reply carries a 3-digit status code that tells you what happened
# BEFORE you even look at the body. Learn these and you can debug any API.
#
#   2xx = Success        (it worked)
#   3xx = Redirection    (go look somewhere else)
#   4xx = Client error   (YOU sent something wrong)
#   5xx = Server error   (the API itself broke)
#
# This script makes one bad call of each class on purpose so you can see them.
# The -w "...%{http_code}..." flag prints the code curl received.

echo "=== 2xx SUCCESS: a normal, correct call ==="
curl -s -o /dev/null -w "Got: %{http_code}  (200 = OK)\n" \
  "https://deckofcardsapi.com/api/deck/new/shuffle/"

echo "=== 3xx REDIRECT: http:// instead of https:// ==="
# curl does NOT follow redirects unless you add -L, so we see the 301 itself.
curl -s -o /dev/null -w "Got: %{http_code}  (301 = Moved Permanently -> use https)\n" \
  "http://deckofcardsapi.com/api/deck/new/shuffle/"

echo "=== 4xx CLIENT ERROR: a deck_id that does not exist ==="
curl -s -o /dev/null -w "Got: %{http_code}  (404 = Not Found, you asked for something that isn't there)\n" \
  "https://deckofcardsapi.com/api/deck/THISDECKDOESNOTEXIST/draw/?count=2"

echo "=== 5xx SERVER ERROR: count=abc (a number is required) ==="
curl -s -o /dev/null -w "Got: %{http_code}  (500 = Internal Server Error, the API choked on our input)\n" \
  "https://deckofcardsapi.com/api/deck/new/draw/?count=abc"
