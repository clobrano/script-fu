#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
PORT=2222
USER="ubuntu"
ADDR="localhost"

set -x
scp -P$PORT "$1" $USER@$ADDR:~
