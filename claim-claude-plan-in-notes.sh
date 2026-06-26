#!/bin/bash
set -e

# --- CONFIGURATION ---
# The folder where you want your "well-known" notes to live
NOTES_DIR="$HOME/Documents/RedHatNotes/Tasks/"
# --- END CONFIGURATION ---

# Ensure the notes directory exists
mkdir -p "$NOTES_DIR"

# Check if a file was provided
if [ -z "$1" ]; then
    echo "Usage: $(basename $0) <path_to_claude_plan.md>"
    exit 1
fi

TARGET_FILE="$1"
TITLE=$2
if [ -z "$TITLE" ]; then
    # 1. Extract the Title (First # Heading)
    # This looks for the first lines starting with '# ' and strips the symbol and leading spaces
    TITLE=$(grep -m 10 '^# ' "$TARGET_FILE" | sed 's/^# *//')
fi


# 2. Format the Filename (Lowercases, replaces spaces/special chars with dashes)
CLEAN_NAME=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\{2,\}/-/g' | sed 's/^-//;s/-$//')
DEST_PATH="$NOTES_DIR/$CLEAN_NAME.md"

# 3. Handle the Move and Symlink
if [ -f "$DEST_PATH" ]; then
    echo "Note '$CLEAN_NAME.md' already exists. Aborting to prevent overwrite."
    exit 1
fi

echo "Claiming $TARGET_FILE to $DEST_PATH. Continue?"
read -r

# Move the actual content to your notes folder
mv "$TARGET_FILE" "$DEST_PATH"

# Create the symlink in Claude's folder pointing to your note
ln -s "$DEST_PATH" "$TARGET_FILE"

echo "------------------------------------------------"
echo "Plan Claimed!"
echo "Source:  $TARGET_FILE"
echo "Linked To: $DEST_PATH"
echo "------------------------------------------------"

