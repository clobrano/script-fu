#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
command -v kdialog > /dev/null
if [ $? -eq 0 ]; then
    task=`kdialog --geometry 600x100+200+200 \
        --title QuickTask \
        --inputbox "For the Inbox" "Buy some milk"`
fi

command -v termux-setup-storage > /dev/null
if [ $? -eq 0 ]; then
    task=`termux-dialog text -t "QuickTask" -i "Buy some milk" | jq -r .text`
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
fi

if [ -n "$task" ]; then
    out=$(task add "$task" +inbox)
    if [ $? -eq 0 ]; then
        $NOTIFY "$out"
    else
        $WARNING "$out"
    fi
fi
