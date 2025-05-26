#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

API_JSON="/tmp/sunset.json"

NOTIFYSEND_ARGS=(--app-name "Sunset reminder" -i dialog-information)
INFO="notify-send ${NOTIFYSEND_ARGS[*]}"
NOTIFYSEND_ARGS=(--app-name "Sunset reminder" -i dialog-warning -u critical)
WARNING="notify-send ${NOTIFYSEND_ARGS[*]}"


if rem | grep "Look at the sunset" -c >/dev/null; then
    $INFO "Sunset reminder already set"
    exit 0
fi

if ! curl "https://api.sunrise-sunset.org/json?lat=39.242901&lng=-9.195257&formatted=0" > "$API_JSON"; then
    $WARNING "[!] could not curl API data"
    exit 1
fi

if STATUS=$(jq -r .status "$API_JSON"); then
    if [ "$STATUS" != "OK" ]; then
        $WARNING "[!] could not get sunset data: status $STATUS"
        exit 1
    fi
fi

SUNSET=$(jq -r .results.sunset "$API_JSON")
$INFO "Sunset attended for $(TZ='Europe/Rome' date -d "$SUNSET" +"%F %H:%M")"

TIME=$(date -d "$SUNSET" +"%H:%M")
rem Look at the sunset at:"$TIME"
