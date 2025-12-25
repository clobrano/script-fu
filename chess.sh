#!/bin/bash

# --- CONFIGURATION ---
USERNAME="clobrano" # <<< REPLACE THIS with your Chess.com username
OUTPUT_DIR="/tmp/daily_games"       # Directory to save the final PGN files
# ---------------------

# --- CHECK FOR DEPENDENCY ---
if ! command -v jq &> /dev/null; then
    echo "ERROR: 'jq' is not installed. Please install it to process the API JSON data."
    echo "  Example install: sudo apt install jq (Linux) or brew install jq (macOS)"
    exit 1
fi

# --- DATE VARIABLES ---
CURRENT_YEAR=$(date +%Y)
CURRENT_MONTH=$(date +%m)
CURRENT_DATE_PGN=$(date +%Y.%m.%d) # Format used in PGN header: [Date "YYYY.MM.DD"]

# --- FILENAMES AND URLS ---
JSON_FILE="${OUTPUT_DIR}/${USERNAME}_${CURRENT_YEAR}-${CURRENT_MONTH}_full.json"
DAILY_PGN_FILE="${OUTPUT_DIR}/${USERNAME}_${CURRENT_DATE_PGN}_daily.pgn"
API_URL="https://api.chess.com/pub/player/${USERNAME}/games/${CURRENT_YEAR}/${CURRENT_MONTH}" # Changed to JSON API

# --- MAIN SCRIPT ---

echo "Starting download for user: ${USERNAME}"
echo "Target Date (PGN format): ${CURRENT_DATE_PGN}"
echo "---"

# 1. Create the output directory if it doesn't exist and empty the previous daily file
mkdir -p "$OUTPUT_DIR" > "$DAILY_PGN_FILE" # Clear the previous daily file

# 2. Download the full monthly JSON data
echo "1. Downloading monthly JSON archive from API: ${API_URL}"
curl -sS -o "$JSON_FILE" "$API_URL"

if [ $? -ne 0 ] || [ ! -s "$JSON_FILE" ]; then
    echo "ERROR: Failed to download the monthly JSON data or file is empty."
    rm -f "$JSON_FILE"
    exit 1
fi

echo "   -> Saved full monthly JSON to: ${JSON_FILE}"

# 3. Filter the JSON data for today's games and extract the full PGN
echo "2. Filtering for games played on: ${CURRENT_DATE_PGN}"

# Use jq to:
# 1. Select the '.games[]' array.
# 2. Filter the games whose '.pgn' string contains the target date tag.
# 3. Output the raw PGN string from the game object, appending it to the daily PGN file.
jq -r --arg DATE_FILTER "[Date \"$CURRENT_DATE_PGN\"]" \
   '.games[] | select(.pgn | contains($DATE_FILTER)) | .pgn' \
   "$JSON_FILE" >> "$DAILY_PGN_FILE"

# 4. Check results and clean up
if [ -s "$DAILY_PGN_FILE" ]; then
    GAME_COUNT=$(grep -c '\[Event "' "$DAILY_PGN_FILE")
    echo "---"
    echo "✅ SUCCESS! Found ${GAME_COUNT} complete games for ${CURRENT_DATE_PGN}."
    echo "   -> Daily PGN saved to: ${DAILY_PGN_FILE}"
else
    echo "---"
    echo "ℹ️ INFO: No games found for ${CURRENT_DATE_PGN} or an issue occurred during filtering."
    rm -f "$DAILY_PGN_FILE" # Clean up empty file
fi

# Optional: Remove the large monthly JSON file to save space
# rm -f "$JSON_FILE"
