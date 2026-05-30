#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
# Use default taskwarrior binary if not set externally
#set -ex
if ! command -v task >/dev/null; then
    exit 0
fi

TASK="task rc:~/.taskworkrc"

DUE_TODAY=$(${TASK} +PENDING +TODAY count)
DUE_TODAY_DONE=$(${TASK} -PENDING +TODAY count)

OVERDUE=$(${TASK} +OVERDUE count)

DUE_THIS_WEEK=$(${TASK} due.after=sow due.before=eow count)
DUE_THIS_WEEK_DONE=$(${TASK} status:completed due.after=sow due.before=eow count)

ACTIVE=$(${TASK} +doing count)

# `count` command doesn't seem to work with `completed` items
DONE_THIS_WEEK=$(${TASK} status:completed end.after=sow end.before=eow count)

echo 󰻌 ${OVERDUE:-?} 󱄻 ${DUE_TODAY_DONE:-?}/${DUE_TODAY:-?} 󰚻 ${DUE_THIS_WEEK_DONE:-?}/${DUE_THIS_WEEK:-?} 󰫚 ${ACTIVE:-?} 󰕥 ${DONE_THIS_WEEK:-?} > $HOME/.taskwarrior-stats
