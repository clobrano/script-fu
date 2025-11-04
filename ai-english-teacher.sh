#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
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
gemini --prompt "Evaluate briefly (200 words top) the following paragraph as an english teacher (grades A, B, or C). You will also provide 2 new versions improving english form and clarity --- $SUBMITTED" >> "$OUTFILE" 

"$HOME"/workspace/script-fu/agent-alert.sh "English teacher grade ready on $OUTFILE"
