#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
PORT=2222
USER="carlo"
ADDR="localhost"

for file in "$@"; do
    cmd="scp -P$PORT ${file} $USER@$ADDR:~"
    echo $cmd
    $cmd
done

