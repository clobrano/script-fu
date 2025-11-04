#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Notification system to let AI agent send desktop notifications

MESSAGE=$1
TITLE=""
if [ -n "$TMUX" ]; then
    echo "You are inside a tmux session."
    sessionName=$(tmux display-message -p '#S')
    TITLE="[$sessionName]"
fi
TITLE="${TITLE} ${PWD/#$HOME/}"
notify-send --app-name "${TITLE}" --icon "info" --expire-time=15000 "${MESSAGE}"

echo "alert-agent done"
