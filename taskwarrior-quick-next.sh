#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
TERMUX_CUSTOM=""
if command -v termux-setup-storage > /dev/null; then
    TERMUX_CUSTOM="rc.data.location=$HOME/storage/documents/Me/Taskwarrior"
fi
out=$(task "$TERMUX_CUSTOM" +PENDING \(+OVERDUE or +TODAY or priority:H or +ACTIVE\) tag.not=main sl)

if command -v kdialog > /dev/null; then
    kdialog --geometry 600x100+200+200 \
        --title Next \
        --msgbox "$out"
fi

if command -v termux-setup-storage > /dev/null; then
    termux-notification --content "$out"
fi
