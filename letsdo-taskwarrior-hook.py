#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vi: set ft=python :

import sys
import json
import subprocess

ORIGINAL = sys.stdin.readline()
MODIFIED = sys.stdin.readline()

TASK = json.loads(MODIFIED)
PROJECT = TASK.get("project", None)
TAGS = TASK.get("tags", None)

LESTDO_CMD = TASK["description"]

if TAGS:
    TAG_LINE = ""
    for tag in TAGS:
        TAG_LINE += " #" + tag
    LESTDO_CMD += TAG_LINE

if PROJECT:
    LESTDO_CMD = "+" + PROJECT + " " + LESTDO_CMD

ERR = 0
if "start" in MODIFIED and not "start" in ORIGINAL:
    # task started
    p = subprocess.Popen(
        ['lets', 'do', LESTDO_CMD],
        stdout=subprocess.PIPE
    )
    OUT, ERR = p.communicate()
    print(OUT)

if "start" in ORIGINAL and not "start" in MODIFIED:
    # task stopped
    p = subprocess.Popen(
        ['lets', 'stop'],
        stdout=subprocess.PIPE
    )
    OUT, ERR = p.communicate()
    print(OUT)


sys.stdout.write(MODIFIED)

sys.exit(ERR)
