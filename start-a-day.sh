#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Fun script to remind you to call it a day after the required hours of work

: ${TASK:="task"}
TASK="${TASK} sl rc.color=off"

# Set the required hours of work (included 1h for lunch) from input or default to 9
required_hours=${1:-9}
commit_daily_update=$(( $required_hours - 1 ))
TODAY_REM=~/.config/rem/rem.$(date +%F)

if [[ ! -f ${TODAY_REM} ]]; then
    echo "$(date +"%b/%d/%Y %H:%M") start of the day" > ~/.config/rem/rem.$(date +%F)
    rem commit daily updates in:${commit_daily_update} hours
    rem call it a day in:${required_hours} hours

    echo `date +%H:%M` > $HOME/.productive-time-started
    echo `date -d "$required_hours hours" +%H:%M` > $HOME/.productive-time-deadline

    lets do morning review
fi

command -v ${TASK} >/dev/null
if [[ $? -ne 0 ]]; then
    exit 0
fi

echo ""
echo "## Quarter Goals"
${TASK} project:QC +PENDING

echo ""
echo "## NEXT (overdue/today/high/active)"
${TASK} "+OVERDUE or +TODAY or priority:H or +ACTIVE -COMPLETE"

echo ""
echo "## THIS WEEK"
${TASK} +PENDING due.after:sow due.before:eow
