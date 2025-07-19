#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
# shellcheck source=/dev/null
# To create a Secret
# * go to Google developer console
# * select API and Services https://console.cloud.google.com/apis/credentials?authuser=1&inv=1&invt=Ab0LjA&orgonly=true&project=taskwarriortogcalsync&supportedpurview=organizationId
# * click on Create Credentials drop-down menu and select OAuth Client ID, type Desktop application. Choose whatever name you prefer
# * once created, use "download JSON" from the pop-up window.
#
set -u
TaskwarriorAgenda sync --calendar "To-do" --filter "+rem -DELETED modified.after=-7d"
