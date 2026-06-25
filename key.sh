#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -o pipefail
ACCOUNT=${1:-$YUBIKEY_ACCOUNT}

echo "$ACCOUNT"
if [ -z "${ACCOUNT}" ]; then
    notify-send --app-name "YKMAN" -u critical "Yubikey error" "YUBIKEY_ACCOUNT was not set" && exit 
    exit 1
fi

if ! command -v ykman >/dev/null; then
    sudo dnf install -y yubikey-manager || exit 1
fi

VALUE=$(kdialog --title "Password" --password "Input Yubikey password" | ykman oath accounts code "$ACCOUNT" | awk '{print $3}')
rc=$?
if [ $rc -ne 0 ]; then
    notify-send --app-name "YKMAN" -u critical "Yubikey error" "Could not get password (error $rc)"
else
    echo -n "$VALUE" | wl-copy
    notify-send --app-name "YKMAN" -i dialog-information "Yubikey" "$VALUE"
fi
