#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
CALENDAR="To-do"
set -u
tw_gcal_sync --gcal-calendar "$CALENDAR" --taskwarrior-tags rem --google-secret "$CALJSONPATH" --default-event-duration-mins 15
