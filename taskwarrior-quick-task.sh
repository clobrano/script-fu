#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
: "${ME:=$HOME/Me}"
if command -v kdialog > /dev/null; then
    description=$(kdialog --geometry 600x100+200+200 \
        --title QuickTask \
        --inputbox "For the Inbox" "Buy some milk")
fi

if command -v termux-setup-storage > /dev/null; then
    description=$(termux-dialog text -t "QuickTask" -i "Buy some milk" | jq -r .text)
fi

# Default notification system is stdout
NOTIFY="echo"
WARNING="echo [!]"

if command -v notify-send > /dev/null; then
    NOTIFY="notify-send --app-name QuickTask -i dialog-information"
    WARNING="notify-send --app-name QuickTask -i dialog-information"
fi

if command -v termux-setup-storage > /dev/null; then
    NOTIFY="termux-notification --content"
    WARNING="termux-notification --content"
    CUSTOM="rc.data.location=$HOME/storage/documents/Me/Taskwarrior"
else
    CUSTOM="rc.data.location=$ME/Taskwarrior"
fi

if [ -n "$description" ]; then
    # description must be without quotes, as it includes other tokens (due, project...)
    out=$(task "$CUSTOM" add $description +inbox)
    rc=$?
    if [ $rc -eq 0 ]; then
        $NOTIFY "$out"
    else
        $WARNING "could not create task - $description - (error: $rc: $out)"
    fi
fi
