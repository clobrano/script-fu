#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
# Use default taskwarrior binary if not set externally
#set -ex
if ! command -v task >/dev/null; then
    exit 0
fi

TASK="task rc:~/.taskworkrc"

DUE_TODAY=$(${TASK} +PENDING +TODAY count)

OVERDUE=$(${TASK} +OVERDUE count)

DUE_THIS_WEEK=$(${TASK} +PENDING due.after=sow due.before=eow count)

ACTIVE=$(${TASK} +ACTIVE count)

# `count` command doesn't seem to work with `completed` items
DONE_THIS_WEEK=$(${TASK} completed end.after=sow end.before=eow | grep -E "^ -" -c)

echo 󰻌 ${OVERDUE:-?} 󱄻 ${DUE_TODAY:-?} 󰚻 ${DUE_THIS_WEEK:-?} 󰫚 ${ACTIVE:-?} 󰕥 ${DONE_THIS_WEEK:-?} > $HOME/.taskwarrior-stats
