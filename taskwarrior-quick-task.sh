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

if [ -n "$task" ]; then
    task add "$task" +inbox
fi

