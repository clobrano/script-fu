#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
: ${ME:=$HOME/Me}
command -v kdialog > /dev/null
if [ $? -eq 0 ]; then
    description=`kdialog --geometry 600x100+200+200 \
        --title QuickTask \
        --inputbox "For the Inbox" "Buy some milk"`
fi

command -v termux-setup-storage > /dev/null
if [ $? -eq 0 ]; then
    description=`termux-dialog text -t "QuickTask" -i "Buy some milk" | jq -r .text`
fi

# Default notification system is stdout
NOTIFY="echo"
WARNING="echo [!]"

command -v notify-send > /dev/null
if [ $? -eq 0 ]; then
    NOTIFY="notify-send --app-name QuickTask -i dialog-information"
    WARNING="notify-send --app-name QuickTask -i dialog-information"
fi

command -v termux-setup-storage > /dev/null
if [ $? -eq 0 ]; then
    NOTIFY="termux-notification --content"
    WARNING="termux-notification --content"
    CUSTOM="rc.data.location=$HOME/storage/documents/Me/Taskwarrior"
else
    CUSTOM="rc.data.location=$ME/Taskwarrior"
fi

if [ -n "$description" ]; then
    out=$(task $CUSTOM add $description +inbox)
    rc=$?
    if [ $rc -eq 0 ]; then
        $NOTIFY "$out"
    else
        $WARNING "could not create task - $description - (error: $rc: $out)"
    fi
fi
