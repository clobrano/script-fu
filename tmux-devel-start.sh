#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

sessions=(
    devel
    code-reviews
    scratchpad
    note
    )

for s in "${sessions[@]}"; do
    if tmux has-session -t "$s" 2>/dev/null; then
        echo "$s session already exists"
    else
        tmux new-session -s "$s" -d
    fi
done

tmux attach -t "${sessions[0]}"

