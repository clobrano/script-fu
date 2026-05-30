#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Notification system to let AI agent send desktop notifications
MESSAGE=$(jq -r '.message')
APP_NAME="💬 Agent notification"

LOCATION=""
if [ -n "$TMUX" ]; then
    sessionName=$(tmux display-message -p '#S')
    LOCATION="[$sessionName] "
fi
#TITLE="${TITLE}${PWD/#$HOME/}"
LOCATION="${LOCATION}$(basename "$(pwd)")"

notify-send --app-name "${APP_NAME}" --expire-time=15000 "${MESSAGE}" "${LOCATION}" 
