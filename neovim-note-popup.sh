#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -eu

noteDirectory="$ME/Notes"
noteFilename="${noteDirectory}/Journal/$(date +%Y-%m-%d.md)"

if [[ ! -f "$noteFilename" ]]; then
    # 2024-08-21: Obsidian template uses some Templater specific things that
    # don't make sense here. Replicating them here
    # Template will be
    #
    # Last:
    # . week: [[7 days ago link]]
    # . month: [[1 month ago link]]
    # . year: [[1 year ago link]]
    cat << EOF > "$noteFilename"
Last:
. week: [[`date -d "last week" +%Y-%m-%d`]]
. month: [[`date -d "last month" +%Y-%m-%d`]]
. year: [[`date -d "last year" +%Y-%m-%d`]]

## `LC_TIME=C date +"%d %a"`
EOF
fi

cd ${noteDirectory}
nvim \
    -c "norm Go" \
    -c "norm Go$(date +%H:%M)" \
    -c "norm zz" \
    -c "norm Go" \
    -c "startinsert" \
    "$noteFilename"


