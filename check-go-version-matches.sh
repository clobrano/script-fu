#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
if [[ -f go.mod ]]; then
    go_mod_ver=`grep -e "^go" | cut -d" " -f 2`
    current_go_version=`go version`
    if [[ !  "$current_go_version" == *"$go_mod_ver"* ]]; then
        echo "[!] go.mod version differ from current go binary version ($go_mod_ver != $current_go_version)"
    fi
fi
