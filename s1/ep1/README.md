# CCNA Automation Prep — Season 1, Episode 1: Intro to APIs

This is **Episode 1 of Season 1** of a CCNA Automation prep series. It introduces
REST APIs the way the CCNA Automation exam topics frame them: making HTTP calls,
reading the JSON that comes back, understanding HTTP verbs (GET/POST), and
interpreting HTTP status codes.

You work through two sets of examples, easiest first:

1. **Deck of Cards API** — a free, public, **no-authentication** API. The gentlest
   possible first contact with REST so you can focus on the mechanics.
2. **Meraki Dashboard API** — a real, **authenticated** enterprise API. Same
   mechanics, plus the one new thing: an `Authorization: Bearer` header.

Everything is provided two ways: as **bash + curl + jq** scripts (run from your
shell) and as a **Bruno collection** (run from a GUI API client). Pick whichever
matches how you like to learn.

---

## Prerequisites

Install these before running anything:

| Tool | Why | Install (macOS) |
|------|-----|-----------------|
| `curl` | Makes the HTTP requests | Pre-installed on macOS/Linux |
| `jq` | Pretty-prints and filters JSON | `brew install jq` |
| Bruno *(optional)* | GUI alternative to the scripts | `brew install --cask bruno` or [usebruno.com](https://www.usebruno.com) |

**For the Meraki examples only**, you also need:

- A **Meraki Dashboard account** with API access enabled
  (Dashboard → *Organization → Settings → Enable API access*).
- A **Meraki API key** (Dashboard → *My Profile → API access → Generate key*).
- Export the key into your shell **before** running the `1x` scripts:

  ```bash
  # bash / zsh
  export MERAKI_API_KEY="your-api-key-here"
  ```

  ```fish
  # fish (this project's shell) — child processes inherit it
  set -gx MERAKI_API_KEY "your-api-key-here"
  ```

  The scripts themselves run under `bash` (via their shebang); the `export`/`set`
  above just puts the key in the environment they inherit. The Deck of Cards
  scripts (`0x`) need **no** key.

> The scripts are intentionally kept at CCNA-Automation level: they set only the
> variable required and run the curl. They do **not** do defensive checks on
> files or variables — if a key or ID is missing you'll see the API's real error
> response, which is itself a useful teaching moment.

---

## Files in this directory

### [`deck/`](./deck) — Deck of Cards (no auth)

| File | Verb | Summary |
|------|------|---------|
| [`deck/01_new_deck.sh`](./deck/01_new_deck.sh) | GET | Your first API call. Shuffles a new deck and returns a `deck_id` to reuse. |
| [`deck/02_draw_cards.sh`](./deck/02_draw_cards.sh) | GET | Draws 5 cards from a deck. Shows path vs. query parameters. Usage: `./02_draw_cards.sh <deckId>`. |
| [`deck/03_reshuffle.sh`](./deck/03_reshuffle.sh) | POST | Reshuffles an existing deck. Introduces POST (change state) vs. GET (read). Usage: `./03_reshuffle.sh <deckId>`. |
| [`deck/04_status_codes.sh`](./deck/04_status_codes.sh) | GET | Makes one deliberately-bad call of each class so you see **200 / 301 / 404 / 500** live. |

### [`meraki/`](./meraki) — Meraki Dashboard (requires `MERAKI_API_KEY`)

| File | Verb | Summary |
|------|------|---------|
| [`meraki/11_get_orgs.sh`](./meraki/11_get_orgs.sh) | GET | Lists every organization your key can see. Grab an org `id` for the next step. |
| [`meraki/12_get_networks.sh`](./meraki/12_get_networks.sh) | GET | Lists networks in one org. Usage: `./12_get_networks.sh <orgId>`. |
| [`meraki/13_get_devices.sh`](./meraki/13_get_devices.sh) | GET | Lists all devices in one network. Usage: `./13_get_devices.sh <networkId>`. |
| [`meraki/14_get_clients.sh`](./meraki/14_get_clients.sh) | GET | Lists clients seen on a network (last 24h via `timespan`). Usage: `./14_get_clients.sh <networkId>`. |
| [`meraki/24_status_codes.sh`](./meraki/24_status_codes.sh) | GET | Status codes against an authenticated API. Shows **200 / 301 / 401** live and documents 400/404/429/5xx. |

### Bruno collection

| File | Summary |
|------|---------|
| [`ccnaauto_api_collection.json`](./ccnaauto_api_collection.json) | All of the above as an importable Bruno collection. Auto-chains IDs between requests via environment variables. |

---

## Running the examples

### Option A — bash scripts

```bash
# Make them executable (one time)
chmod +x deck/*.sh meraki/*.sh

# --- Deck of Cards (no key needed) ---
cd deck
./01_new_deck.sh                 # copy the deck_id from the output
./02_draw_cards.sh <deckId>
./03_reshuffle.sh <deckId>
./04_status_codes.sh             # see 200 / 301 / 404 / 500
cd ..

# --- Meraki (set MERAKI_API_KEY first, see Prerequisites) ---
cd meraki
./11_get_orgs.sh                 # copy an org id
./12_get_networks.sh <orgId>     # copy a network id
./13_get_devices.sh <networkId>
./14_get_clients.sh <networkId>
./24_status_codes.sh             # see 200 / 301 / 401
```

Each script prints its **HTTP status code** to the terminal while the JSON body
flows into `jq`. Every script also lists copy-paste **jq hints** in its comments
for trimming the output (e.g. `jq '.[] | {name, id}'`).

### Option B — Bruno

1. Open Bruno → **Import Collection → Bruno Collection** → pick
   `ccnaauto_api_collection.json`.
2. Select the **`ccnaauto`** environment (top-right dropdown).
3. Paste your key into the `MERAKI_API_KEY` environment variable.
4. Run requests top to bottom. The "list" requests save IDs (`deck_id`,
   `org_id`, `network_id`) into the environment automatically, so later requests
   just work — no copy/paste.

> **Note on the 301 redirect examples:** Bruno follows redirects by default, so
> the `http://` examples may land on a 2xx instead of showing the 301. To *see*
> the 301, turn off **Follow Redirects** in that request's **Settings** tab —
> the GUI equivalent of `curl` needing `-L` to follow a redirect.

---

## HTTP status codes cheat sheet

The single most important debugging skill with any API:

| Class | Meaning | Example here |
|-------|---------|--------------|
| **2xx** | Success — it worked | `200 OK` |
| **3xx** | Redirection — look elsewhere | `301` (used `http` not `https`) |
| **4xx** | Client error — *you* sent something wrong | `404` (bad ID), `401` (bad key) |
| **5xx** | Server error — the API itself broke | `500` (sent `count=abc`) |
