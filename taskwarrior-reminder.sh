#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -x
TASK=${1:-task}
JQ=${2:-jq}

if command -v termux-setup-storage > /dev/null 2>&1; then
    ON_TERMUX=1
else
    ON_TERMUX=0
fi

if [ "$ON_TERMUX" -eq 0 ]; then
    NOTIFY="/usr/bin/notify-send --app-name Taskwarrior -i dialog-information -u critical"
    WARNING="/usr/bin/notify-send --app-name Taskwarrior -i dialog-information -u critical"
else
    NOTIFY="termux-notification --content"
    WARNING="termux-notification --content"
    TASKRC="rc.data.location=$HOME/storage/documents/Me/Taskwarrior"
fi

TASK="$TASK $TASKRC"

# DUE
count=$($TASK +PENDING due.after:now due.before:now+15min export | $JQ 'keys | length')
if [ -z "$count" ]; then
    exit 0
fi

if [ "$count" -gt 0 ]; then
    if ! out=$($TASK rc.verbose=nothing due.after:now due.before:now+15min sort:due sl | awk '{for(i=3;i<=NF;i++) printf "%s ", $i; print "- due in " $2}'); then
        $WARNING "could not notify tasks"
    else
        $NOTIFY "$out"
        #if [ "$ON_TERMUX" -eq 0 ]; then
            #ntfy-send.sh --message "$out" --channel "$TASKWARRIOR_CHANNEL"
        #fi
    fi
fi

sleep 1

# SCHEDULED
count=$($TASK +PENDING scheduled.after:now scheduled.before:now+15min export | $JQ 'keys | length')
if [ -z "$count" ]; then
    exit 0
fi

if [ "$count" -gt 0 ]; then
    if ! out=$($TASK rc.verbose=nothing scheduled.after:now scheduled.before:now+15min sort:scheduled sl | awk '{ for(i=3;i<=NF;i++) printf "%s ", $i; print "- scheduled in " $2}'); then
        $WARNING "could not notify tasks: error $?"
    else
        $NOTIFY "$out"
        #if [ "$ON_TERMUX" -eq 0 ]; then
            #ntfy-send.sh --message "$out" --channel "$TASKWARRIOR_CHANNEL"
        #fi
    fi
fi
