#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -eu

noteFilename="$HOME/Dropbox/notes/Journal/$(date +%Y-%m-%d.md)"

if [[ ! -f "$noteFilename" ]]; then
    # this is shared with Obsidian, so I need to use the same template.
    TEMPLATE="$HOME/Dropbox/notes/Resources/templates/notes-day.md"
    if [[ ! -f "$TEMPLATE" ]]; then
        echo "[!] can't find template: $TEMPLATE"
        exit 1
    fi
    cat "$HOME/Dropbox/notes/Resources/templates/notes-day.md" > "$noteFilename"
fi

set -x
nvim \
    -c "norm Go" \
    -c "norm Go$(date +%H:%M)" \
    -c "norm zz" \
    -c "norm Go" \
    -c "startinsert" \
    "$noteFilename"


