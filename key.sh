#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
ENCRIPTED_FILE=$1
ACCOUNT=$2

VALUE=$(kdialog --title "Password" --password "Input Yubikey password" | ykman oath accounts code $ACCOUNT | awk '{print $3}')
code=$?
if [ $code -ne 0 ]; then
    notify-send --app-name "YKMAN" -u critical "Yubikey error" "$code"
else
    echo -n $VALUE | wl-copy
    notify-send --app-name "YKMAN" -i dialog-information "Yubikey" "$VALUE"
fi
