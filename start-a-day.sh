#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Fun script to remind you to call it a day after the required hours of work
: "${TASK:="task"}"

# Set the required hours of work (included 1h for lunch) from input or default to 9
required_hours=${1:-9}
commit_daily_update=$(( required_hours - 1 ))
TODAY_REM=~/.config/rem/rem.$(date +%F)

if [ ! -f "${TODAY_REM}" ]; then
    echo "$(date +"%b/%d/%Y %H:%M") start of the day" > ~/.config/rem/rem."$(date +%F)"
    rem commit daily updates in:${commit_daily_update} hours
    rem call it a day in:"${required_hours}" hours

    date +%H:%M > "$HOME"/.productive-time-started
    date -d "$required_hours hours" +%H:%M > "$HOME"/.productive-time-deadline

    lets do morning review +wk
fi

if ! command -v ${TASK} >/dev/null; then
    exit 0
fi

echo "## NEXT (overdue/today/high/active)"
${TASK} "+OVERDUE or +TODAY or priority:H or +ACTIVE -COMPLETE" | raffaello -r "-=>red"

echo "## THIS WEEK"
${TASK} +PENDING due.after:sow due.before:eow | raffaello -r "-=>red"

echo ""
myagenda
sunset-reminder.sh

