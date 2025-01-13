#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
: "${ME:=$HOME/Me}"
description=$@

# Default notification system is stdout
WARNING="echo [!]"
command -v notify-send > /dev/null
if [ $? -eq 0 ]; then
    WARNING="notify-send --app-name QuickNote -i dialog-warning"
fi

command -v termux-setup-storage > /dev/null
if [ $? -eq 0 ]; then
    ME=$HOME/storage/documents/Me
    WARNING="termux-notification --content"
fi

if [ -z "$description" ]; then
    command -v kdialog > /dev/null
    if [ $? -eq 0 ]; then
        description=$(kdialog --geometry 600x100+200+200 \
            --title QuickNote \
            --textinputbox "What are you thinking?")
    fi

    command -v termux-setup-storage > /dev/null
    if [ $? -eq 0 ]; then
        description=`termux-dialog text -t "What are you thinking?" -i "I conquered the world today" | jq -r .text`
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
. week: [[`date -d "last week" +%Y-%m-%d`]]
. month: [[`date -d "last month" +%Y-%m-%d`]]
. year: [[`date -d "last year" +%Y-%m-%d`]]

## `LC_TIME=C date +"%d %a"`
EOF
fi
rc=$?
if [ $rc -ne 0 ]; then
    $WARNING "could not create note $noteFilename: error $rc"
    exit 1
fi

echo "" >> "$noteFilename"
echo `LC_TIME=C date +"%H:%M"` >> "$noteFilename"
echo $description >> "$noteFilename"
rc=$?
if [ $rc -ne 0 ]; then
    $WARNING "could not update note: error $rc"
    exit 1
fi

if ! command -v termux-setup-storage > /dev/null; then
    curr_dir=$(dirname $0)
    set -x
    out=$("$curr_dir"/neovim-weekly-review.sh)
    rc=$?
    if [ $rc -ne 0 ]; then
        $WARNING "weekly review failed: $out (error: $rc)"
    fi
fi
