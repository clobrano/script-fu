#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

# Get URL from input or clipboard if input is empty
if [ -z "$1" ]; then
    url=$(xclip -o)
else
    url=$1
fi

wget -qO- "$url" | perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)\s*<\/title/si' | recode html..ascii 2>/dev/null
