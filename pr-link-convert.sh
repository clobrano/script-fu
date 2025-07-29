#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -o errexit
set -o pipefail

link=$1

if [ -z "$link" ]; then
    echo "getting the link from clipboard..."
    if ! link=$(wl-paste); then
        echo "[!] could not get the link from clipboard: error $?"
        exit 1
    fi
    if [ -z "$link" ] || [[ "$link" != https://* ]] ; then
        echo "[!] no link found, something went wrong: clipboard had \"$link\""
        exit 1
    fi
fi


if [[ "$link" =~ "github" ]]; then
    if [[ "$link" =~ "pull" ]]; then
        echo "$link" | sed -E 's|https://github.com/([^/]+)/([^/]+)/pull/([0-9]+)|\1/\2 PR\3|'
        echo "$link" | sed -E 's|https://github.com/([^/]+)/([^/]+)/pull/([0-9]+)|\1/\2 PR\3|' | wl-copy
    elif [[ "$link" =~ "issue" ]]; then
        echo "$link" | sed -E 's|https://github.com/([^/]+)/([^/]+)/issues/([0-9]+)|\1/\2 I\3|'
        echo "$link" | sed -E 's|https://github.com/([^/]+)/([^/]+)/issues/([0-9]+)|\1/\2 I\3|' | wl-copy
    fi
fi


