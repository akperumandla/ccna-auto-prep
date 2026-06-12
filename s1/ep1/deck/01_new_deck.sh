#!/usr/bin/env bash
# Intro 1: Your first API call. No authentication needed.
# This shuffles a brand-new deck and gives you back a "deck_id".
# Copy that deck_id and pass it to the next scripts.
#
# GET = "give me data". The simplest, most common API verb.

curl -s -w "%{stderr}HTTP Status: %{http_code}\n" \
  -X GET "https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1" | jq '.'

# The -w "%{stderr}HTTP Status: %{http_code}\n" prints the response code to your
# screen while the JSON body still flows into jq. 200 = OK. See 04_status_codes.sh
# for what the other numbers mean.

# What you get back:
#   deck_id    the ID you reuse in the next calls
#   remaining  how many cards are left (52 for a fresh deck)
#
# jq hints (append after the pipe to trim the output):
#   Just the deck_id ....... jq '.deck_id'
#   Just cards remaining ... jq '.remaining'
