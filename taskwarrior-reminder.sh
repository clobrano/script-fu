#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
#set -x
TASK=${1:-task}
JQ=${2:-jq}

NOTIFY="/usr/bin/notify-send --app-name Taskwarrior -i dialog-information -u critical"
WARNING="/usr/bin/notify-send --app-name Taskwarrior -i dialog-information -u critical"

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
    fi
fi
