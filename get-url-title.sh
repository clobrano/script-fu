#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
wget -qO- "$@" | perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)\s*<\/title/si' | recode html..ascii 2>/dev/null
