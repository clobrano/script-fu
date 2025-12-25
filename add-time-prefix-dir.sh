#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
# Add a time prefix to a directory to distinguish it from others in the same folder

DIR=$1
if [ ! -d "$DIR" ]; then
    echo "[!] $DIR is not a directory"
    exit 1
fi

set -x
mv {,"$(date +%F-%s)"-}"$DIR"
