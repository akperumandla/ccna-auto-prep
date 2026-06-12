#!/usr/bin/env bash
# Intro 2: Draw cards from a deck you already made.
# Usage: ./02_draw_cards.sh <deckId>
# Run 01_new_deck.sh first to get a deckId.
#
# Notice the URL has the deck_id IN THE PATH and "count" as a QUERY parameter
# (the part after the ?). This is how you tell an API exactly what you want.

DECK_ID="$1"

curl -s -w "%{stderr}HTTP Status: %{http_code}\n" \
  -X GET "https://deckofcardsapi.com/api/deck/${DECK_ID}/draw/?count=5" | jq '.'

# jq hints (append after the pipe to trim the output):
#   Just the cards array ... jq '.cards'
#   Card names only ........ jq '.cards[].code'
#   Value + suit ........... jq '.cards[] | {value, suit}'
#   How many left .......... jq '.remaining'
