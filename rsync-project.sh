#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
LOCAL_PROJECT_PATH="$1"
REMOTE_PROJECT_PATH="$2"
REMOTE="${3:-"helios"}"

rsync -avz \
    --exclude '.git/' \
    --exclude 'vendor/' \
    "$LOCAL_PROJECT_PATH" "$REMOTE":"$REMOTE_PROJECT_PATH" \
    < <(git -C "$LOCAL_PROJECT_PATH" ls-files --modified --others --exclude-standard -z)

rc=$?
if [ "$rc" -ne 0 ]; then
    echo "[!] Rsync failed: $LOCAL_PROJECT_PATH ⇒ $REMOTE:$REMOTE_PROJECT_PATH, error: $rc"
    exit 1
fi
echo "[+] Rsync completed: $LOCAL_PROJECT_PATH ⇒ $REMOTE:$REMOTE_PROJECT_PATH, error: $rc"

