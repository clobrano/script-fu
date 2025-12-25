#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## This script acts as an AI English teacher, processing text from the clipboard to provide feedback.
SUBMITTED=$(wl-paste)
OUTFILE=/tmp/english-teacher.md
if echo "$SUBMITTED" | grep -E "http|https" > /dev/null 2>&1; then
    exit 0
fi

# Redirect to a file, so that I can run the script in background and read the result asynchronously
{
    echo "$SUBMITTED"
    echo "---"
} > "$OUTFILE"

notify-send --app-name "AI English Editor" "Reviewing: $SUBMITTED"

$HOME/workspace/toolbelt/geminirh "You are an English teacher and editor. Grade the message after the triple dashes (---) and provide 2 new versions improving english form and clarity --- $SUBMITTED" >> "$OUTFILE"

ACTION_CHOICE=$(notify-send "English Editor is ready" "Open the file?" \
    --expire-time=30000 \
    --action="yes=Yes" \
    --action="no=No" \
    --wait)

# The variable $ACTION_CHOICE now holds the NAME of the button clicked ('yes' or 'no').
# We use a case statement to react to the choice.
case "$ACTION_CHOICE" in
    "yes")
        xdg-open "$OUTFILE"
        # Add your command to run for 'Yes' here
        ;;
    *)
        ;;
esac
