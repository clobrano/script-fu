#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Fun script to remind you to call it a day after the required hours of work

# Set the required hours of work (included 1h for lunch) from input or default to 9
required_hours=${1:-9}
TODAY_REM=~/.config/rem/rem.$(date +%F)

if [[ ! -f ${TODAY_REM} ]]; then
    echo "$(date +"%b/%d/%Y %H:%M") start of the day" >> ~/.config/rem/rem.$(date +%F)
    rem call it a day in:${required_hours} hours

    echo `date +%H:%M` > $HOME/.productive-time-started
    echo `date -d "$required_hours hours" +%H:%M` > $HOME/.productive-time-deadline

    lets do morning review
fi

echo "## OVERDUE/TODAY"
task rc:~/.taskworkrc +OVERDUE +TODAY

echo ""
echo "## THIS WEEK"
task rc:~/.taskworkrc +PENDING due.after:sow due.before:eow


echo ""
echo "## ACTIVE"
task rc:~/.taskworkrc +ACTIVE

