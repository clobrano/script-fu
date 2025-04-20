#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
: "${ME:=$HOME/Me}"
description=$*

# Default notification system is stdout
WARNING="echo [!]"

if command -v notify-send > /dev/null; then
    WARNING="notify-send --app-name QuickNote -i dialog-warning"
fi


if command -v termux-setup-storage > /dev/null; then
    ME=$HOME/storage/documents/Me
    WARNING="termux-notification --content"
fi

if [ -z "$description" ]; then
    if command -v kdialog > /dev/null; then
        description=$(kdialog --geometry 600x100+200+200 \
            --title QuickNote \
            --textinputbox "What are you thinking?")
    fi

    if command -v termux-setup-storage > /dev/null; then
        description=$(termux-dialog text -m -t "What are you thinking?" -i "I conquered the world today" | jq -r .text)
    fi
fi

# if description is still empty we must exit
if [ -z "$description" ]; then
    echo "No description"
    exit 0
fi

noteDirectory="$ME/Notes"
noteFilename="${noteDirectory}/Journal/$(date +%Y-%m-%d.md)"
if [[ ! -f "$noteFilename" ]]; then
    # Template will be
    #
    # Last:
    # . week: [[7 days ago link]]
    # . month: [[1 month ago link]]
    # . year: [[1 year ago link]]
    cat << EOF > "$noteFilename"
Last:
. week: [[$(date -d "last week" +%Y-%m-%d)]]
. month: [[$(date -d "last month" +%Y-%m-%d)]]
. year: [[$(date -d "last year" +%Y-%m-%d]]

)## $(LC_TIME=C date +"%d %a")
EOF
fi
rc=$?
if [ $rc -ne 0 ]; then
    $WARNING "could not create note $noteFilename: error $rc"
    exit 1
fi

echo ""; LC_TIME=C date +"%H:%M" >> "$noteFilename"
echo "$description" >> "$noteFilename"

neovim-weekly-review.sh
