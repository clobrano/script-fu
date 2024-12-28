#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
TERMUX_CUSTOM=""
command -v termux-setup-storage > /dev/null
if [ $? -eq 0 ]; then
    TERMUX_CUSTOM="rc.data.location=$HOME/storage/documents/Me/Taskwarrior"
fi
out=$(task $TERMUX_CUSTOM +PENDING \(+OVERDUE or +TODAY or priority:H or +ACTIVE\) sl)

command -v kdialog > /dev/null
if [ $? -eq 0 ]; then
    description=`kdialog --geometry 600x100+200+200 \
        --font Monospace \
        --title Next \
        --msgbox "$out"`
fi

command -v termux-setup-storage > /dev/null
if [ $? -eq 0 ]; then
    description=`termux-notification --content $out`
fi


