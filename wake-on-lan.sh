#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -u

source ~/.dot/.config/cconf/environment.sh

if ! command -v wakeonlan > /dev/null; then
    echo "[!] wakeonlan missing!"
    exit 1
fi

wakeonlan $LABD_ITC_SW03_MAC
