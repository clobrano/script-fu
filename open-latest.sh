#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

while true; do
    echo "current dir: $PWD"
    LATEST=$(/bin/ls -t | head -1)
    if [ -z "$LATEST" ]; then
        echo "[!] could not find latest file/directory in this location"
        exit 0
    fi

    if file "$LATEST" | grep "directory"; then
        "$(realpath "$LATEST")" | wl-copy
        pushd "$LATEST" || exit 1
        continue
    fi
    break
done

nvim "$LATEST"
