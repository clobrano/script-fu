#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -x
description=$*

if [ -z "$description" ]; then
    description=$(kdialog --geometry 600x100+200+200 --title QuickNote --textinputbox "What are you thinking?")
fi

# if description is still empty we must exit
if [ -z "$description" ]; then
    echo "No description"
    exit 0
fi


"$HOME/workspace/golang/bin/LogBook" log "$description"

