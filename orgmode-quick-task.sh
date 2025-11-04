#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

ORGMODE="$HOME/Me/Orgmode/Orgmode.org"
description="$*"

if [ -z "$description" ]; then
    if command -v kdialog > /dev/null; then
        description=$(kdialog --geometry 600x100+200+200 \
            --title QuickTask \
            --inputbox "Orgmode task for the Inbox" "Buy some milk")
    fi
fi

if [ -n "$description" ]; then
    # Extract date/time substrings
    set -x
    if [[ "$description" =~ " tom " ]]; then
        description=${description//tom/Tomorrow}
    fi
    if  [[ "$description" =~ " Tom " ]]; then
        description=${description//Tom/Tomorrow}
    fi

    if [[ "$description" =~ " Tomorrow " ]]; then
        description=${description//Tomorrow/$(date -d "Tomorrow" "+%b%e")}
    fi

    extracted_datetime=$(echo "$description" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}(\s+[0-9]{2}:[0-9]{2})?|[0-9]{2}/[0-9]{2}/[0-9]{4}(\s+[0-9]{2}:[0-9]{2})?|(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec|monday|mon|tuesday|tue|wednesday|wed|thursday|thu|friday|fri|saturday|sat|sunday|sun)\s+[0-9]{1,2}(\s+[0-9]{2}:[0-9]{2})?')

    # Remove extracted date/time from description if it exists
    if [ -n "$extracted_datetime" ]; then
        description=$(echo "$description" | sed -E "s/$(echo "$extracted_datetime" | sed 's/[[:space:]]/[[:space:]]/g')//")

        
        extracted_datetime=$(date -d "$extracted_datetime" '+%Y-%m-%d %a %H:%M')
        deadline_property="DEADLINE: <${extracted_datetime}>"
    else
        deadline_property="DEADLINE:"
    fi


cat << EOF >> "$ORGMODE"
* TODO ${description}
  ${deadline_property}
  :PROPERTIES:
  :ID:       $(uuidgen)
  :CREATED:  [$(date '+%Y-%m-%d %a %H:%M')]
  :END:
EOF
fi

# Default notification system is stdout
NOTIFY="echo"

if command -v notify-send > /dev/null; then
    NOTIFY="notify-send --app-name OrgmodeTask -i dialog-information"
fi

$NOTIFY "$description $extracted_datetime"
