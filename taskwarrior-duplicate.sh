#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -eux
ID=$1
shift
DESC=$*

task "$ID" duplicate description:"$DESC" depends:"$ID"
task +LATEST annotate "duplicated from $ID"
