#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

TIME=$1
SELECTION=$2

if [[ -z ${SELECTION} ]]; then
    timezone=$(timedatectl list-timezones | \
        fzf --height 40% --reverse \
        --prompt="Select timezone: " \
        --border \
        --multi)

    for t in ${timezone}; do
        echo "- ${t}: $(date --date "TZ=\"${t}\" 11:00" +%H:%M)"
    done
else
    declare -A timezones
    timezones[EST]="America/New_York"
    timezones[IST]="Asia/Kolkata"
    timezones[ICT]="Asia/Bangkok"
    timezones[AEST]="Australia/Melbourne"

    timezone=${timezones[${SELECTION}]}
    if [[ -z ${timezone} ]]; then
        echo "Invalid timezone: ${SELECTION}"
        exit 1
    fi

    echo $(LC_TIME=en_US.UTF-8 date --date "TZ=\"${timezone}\" ${TIME}" +"%I:%M %P") ${SELECTION}
fi
