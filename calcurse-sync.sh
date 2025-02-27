#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -u
if wget "$MYCALENDAR" -O /tmp/mycalendar.ics; then
    echo "[+] cleanup old apts"
    rm "$HOME"/.local/share/calcurse/apts
else
    echo "[!] could not get new apts"
    exit 1
fi

cp "$ME/Notes/1-Projects/IdealWeekPlanner/ideal-week.ics" /tmp/iw.ics

calcurse -i /tmp/mycalendar.ics
calcurse -i /tmp/iw.ics
calcurse -i "$HOME/Documents/calendars/clobrano@redhat.com.ics"
calcurse
