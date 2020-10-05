#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vi: set ft=python :
import sys
import subprocess

ORIGINAL = sys.stdin.readline()
MODIFIED = sys.stdin.readline()

ERR = 0

if "start" in MODIFIED and not "start" in ORIGINAL:
    # task started, check if a timer is running already
    PROC = subprocess.Popen(
        ['redtimer'], stdout=subprocess.PIPE
    )
    OUT, ERR = PROC.communicate()
    print(OUT)

    if "no redtimer" in str(OUT):
        PROC = subprocess.Popen(
            ['redtimer', 'work', '25'],
            stdout=subprocess.PIPE
        )
sys.stdout.write(MODIFIED)

sys.exit(ERR)
