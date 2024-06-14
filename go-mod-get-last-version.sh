#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to get the latest version of a module listed in go.mod

# feed FZF with the list of required modules from go.mod
PROMPT+="Press TAB to select any depedencies you want to update to the latest version"
selection=$(awk '/require \(/,/\)/{if (!/require \(/ && !/\)/) print}' go.mod | \
    fzf --layout reverse --height 70% --border --multi --prompt "$PROMPT")

for module in ${selection}; do
    # some selection is actually the module's version in format vx.y.z. Skipping those
    if [[ $module =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        continue
    fi
    cmd="go get -u ${module}"
    echo ${cmd}
    ${cmd}
done
