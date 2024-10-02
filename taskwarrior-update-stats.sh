#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
# Use default taskwarrior binary if not set externally

command -v task >/dev/null
if [[ $? -ne 0 ]]; then
    exit 0
fi

TASK="task rc:~/.taskworkrc"
export TASKDATA="/home/clobrano/Documents/taskwarriorRH"

## Ignore "no matches" error
DUE_TODAY=$(${TASK} +PENDING +TODAY count)
#[[ $DUE_TODAY -gt 0 ]] && check-error $?

OVERDUE=$(${TASK} +OVERDUE count)
#[[ $OVERDUE -gt 0 ]] && check-error $?

DUE_THIS_WEEK=$(${TASK} +PENDING due.after=sow due.before=eow count)
#[[ $DUE_THIS_WEEK -gt 0 ]] && check-error $?

ACTIVE=$(${TASK} +ACTIVE count)
#[[ $ACTIVE -gt 0 ]] && check-error $?

# `count` command doesn't seem to work with `completed` items
DONE_THIS_WEEK=$(${TASK} completed end.after=sow end.before=eow | grep -E "^ -" -c)
#[[ $DONE_THIS_WEEK -gt 0 ]] && check-error $?

echo 󰻌 ${OVERDUE:-?} 󱄻 ${DUE_TODAY:-?} 󰫚 ${ACTIVE:-?} 󰚻 ${DUE_THIS_WEEK:-?} 󰕥 ${DONE_THIS_WEEK:-?} > $HOME/.taskwarrior-stats
