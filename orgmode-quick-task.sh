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
    extracted_datetime=$(echo "$description" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}(\s+[0-9]{2}:[0-9]{2})?|[0-9]{2}/[0-9]{2}/[0-9]{4}(\s+[0-9]{2}:[0-9]{2})?|(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec|tomorrow|tom|monday|mon|tuesday|tue|wednesday|wed|thursday|thu|friday|fri|saturday|sat|sunday|sun)\s+[0-9]{1,2}(\s+[0-9]{2}:[0-9]{2})?')

    # Remove extracted date/time from description if it exists
    if [ -n "$extracted_datetime" ]; then
        description=$(echo "$description" | sed -E "s/$(echo "$extracted_datetime" | sed 's/[[:space:]]/[[:space:]]/g')//")

        extracted_datetime=$(date -d "$extracted_datetime" '+%Y-%m-%d %a %H:%M')
        deadline_property="DEADLINE: <${extracted_datetime}>"
    else
        deadline_property="DEADLINE:"
    fi


cat << EOF >> "$ORGMODE"
* TODO ${description}:inbox:
  ${deadline_property}
  :PROPERTIES:
  :ID:       $(uuidgen)
  :CREATED:  [$(date '+%Y-%m-%d %a %H:%M')]
  :END:
EOF
fi


