#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -x
: "${ME:=$HOME/Me}"
description=$*

# Default notification system is stdout
WARNING="echo [!]"

command -v termux-setup-storage >/dev/null 2>&1
in_termux=$?

if command -v notify-send > /dev/null; then
    WARNING="notify-send --app-name QuickNote -i dialog-warning"
fi


if [ "$in_termux" -eq 0 ]; then
    ME=$HOME/storage/documents/Me
    WARNING="termux-notification --content"
fi

if [ -z "$description" ]; then
    if [ "$in_termux" -eq 0 ]; then
        description=$(termux-dialog text -m -t "What are you thinking?" | jq -r .text)
    else
        description=$(kdialog --geometry 600x100+200+200 --title QuickNote --textinputbox "What are you thinking?")
    fi
fi

# if description is still empty we must exit
if [ -z "$description" ]; then
    echo "No description"
    exit 0
fi

# add initial outline mark if it doesn't exist already
set -x
if [ "* $description" != "$description" ] || 
    [ "+ $description" != "$description" ] ||
    [ "- $description" != "$description" ]; then
    description="* $description"
fi
set +x

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
. year: [[$(date -d "last year" +%Y-%m-%d)]]


## $(LC_TIME=C date +"%d %a")
EOF
fi
rc=$?
if [ $rc -ne 0 ]; then
    $WARNING "could not create note $noteFilename: error $rc"
    exit 1
fi

{
    echo -e "\n"
    LC_TIME=C date +"%H:%M"
    echo "$description"
    echo
} >> "$noteFilename"


if [ "$in_termux" -eq 0 ]; then
    "$HOME"/workspace/script/neovim-weekly-review.sh
else
    neovim-weekly-review.sh
fi
