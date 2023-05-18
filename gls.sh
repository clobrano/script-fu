#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper scripts that power up bash ls command to show which entry is tracked by Git

FILES=$(ls)
GIT_TRACKED_FILES=$(git ls-tree HEAD --name-only)

for f in ${FILES}; do
    if [[ ${GIT_TRACKED_FILES} == *"${f}"* ]]; then
        echo "T ${f}"
    else
        echo "  ${f}"
    fi
done
