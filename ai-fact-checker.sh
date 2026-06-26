#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## This script acts as an AI English teacher, processing text from the clipboard to provide feedback.
SUBMITTED=$(wl-paste)
OUTFILE=/tmp/ai-fact-checker.md
if echo "$SUBMITTED" | grep -E "http|https" > /dev/null 2>&1; then
    exit 0
fi

# Redirect to a file, so that I can run the script in background and read the result asynchronously
{
    echo "$SUBMITTED"
    echo "---"
} > "$OUTFILE"

notify-send --app-name "AI Fact Checker" "Reviewing: $SUBMITTED"

$HOME/workspace/toolbelt/gm "You are an expert journalist, historic and politic. I want you to fact check the following content providing links and evidences of your finding --- $SUBMITTED" >> "$OUTFILE"

ACTION_CHOICE=$(notify-send "AI Fact checker is ready" "Open the file?" \
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
