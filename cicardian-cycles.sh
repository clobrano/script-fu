#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## This script calculates and displays circadian cycles based on a reference time, with a default cycle length of 90 minutes.

set -e
ref=$1
CYCLES=6
LENGTH=5400 #90 min
if [[ -z $ref ]]; then
    ref_sec=$(date +%s)
else
    ref_sec=$(date --date $ref +%s)
fi

from=$(date --date @$ref_sec +%H:%M)
for i in $(seq 1 $CYCLES ); do
    to=$(date --date @"`echo $ref_sec + $LENGTH \* $i|bc`" +%H:%M)
    echo "$i) $from - $to"
    from=$to
done
