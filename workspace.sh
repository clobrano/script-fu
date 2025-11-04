#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

sessions=(
    0-devel
    1-note
    3-medik8s
    4-code-reviews
    9-scratchpad
    )

attach=0
for s in "${sessions[@]}"; do
    if tmux has-session -t "$s" 2>/dev/null; then
        echo "$s session already exists"
    else
        tmux new-session -s "$s" -d
        attach=1
    fi
done

if [ "$attach" -eq 1 ]; then
    tmux attach -t "${sessions[0]}"
fi

