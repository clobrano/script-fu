#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
TERMUX_CUSTOM=""
command -v termux-setup-storage > /dev/null
if [ $? -eq 0 ]; then
    TERMUX_CUSTOM="rc.data.location=$HOME/storage/documents/Me/Taskwarrior"
fi
out=$(task $TERMUX_CUSTOM +PENDING \(+OVERDUE or +TODAY or priority:H or +ACTIVE\) tag.not=main sl)

command -v kdialog > /dev/null
if [ $? -eq 0 ]; then
    kdialog --geometry 600x100+200+200 \
        --title Next \
        --msgbox "$out"
fi

command -v termux-setup-storage > /dev/null
if [ $? -eq 0 ]; then
    termux-notification --content "$out"
fi


