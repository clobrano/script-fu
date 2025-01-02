#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -o pipefail
ENCRIPTED_FILE=$1
ACCOUNT=$2

VALUE=$(kdialog --title "Password" --password "Input Yubikey password" | ykman oath accounts code $ACCOUNT | awk '{print $3}')
rc=$?
if [ $rc -ne 0 ]; then
    notify-send --app-name "YKMAN" -u critical "Yubikey error" "could not get password (error $rc)"
else
    echo -n $VALUE | wl-copy
    notify-send --app-name "YKMAN" -i dialog-information "Yubikey" "$VALUE"
fi
