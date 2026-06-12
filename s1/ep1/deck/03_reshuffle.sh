#!/usr/bin/env bash
# Intro 3: Reshuffle an existing deck. This uses POST instead of GET.
# Usage: ./03_reshuffle.sh <deckId>
#
# GET asks for data; POST asks the server to DO something / change state.
# Here we are telling the server "shuffle this deck back together".
# Many real APIs (like creating a config) use POST the same way.

DECK_ID="$1"

curl -s -w "%{stderr}HTTP Status: %{http_code}\n" \
  -X POST "https://deckofcardsapi.com/api/deck/${DECK_ID}/shuffle/" | jq '.'

# jq hints (append after the pipe to trim the output):
#   Confirm it worked ...... jq '.shuffled'
#   Cards back in deck ..... jq '.remaining'
