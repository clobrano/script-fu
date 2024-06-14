#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Fun script to remind you to call it a day after the required hours of work

# Set the required hours of work (included 1h for lunch) from input or default to 9
required_hours=${1:-9}

#echo "notify-send '${required_hours} have passed, call it a day!'" | at now + ${required_hours} hours
rem call it a day in:${required_hours} hours
#echo "notify.sh --local --message \"call it a day!\"" | at now + ${required_hours} hours

if [[ -n $_get ]]; then
    cat $HOME/.productive-time-started
    exit 0
fi
echo `date +%H:%M` > $HOME/.productive-time-started
echo `date -d "$required_hours hours" +%H:%M` > $HOME/.productive-time-deadline
