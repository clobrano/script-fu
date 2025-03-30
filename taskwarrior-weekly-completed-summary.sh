#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
TERMUX_CUSTOM=""
if command -v termux-setup-storage > /dev/null; then
    TERMUX_CUSTOM="rc.data.location=$HOME/storage/documents/Me/Taskwarrior"
fi

task "$TERMUX_CUSTOM" weekly_completed
task "$TERMUX_CUSTOM" status:completed end.after:sow export | jq -r '.[] | select(.project != null) | .project' | sort | uniq -c | awk '{printf "%-20s %d\n", $2, $1}'
