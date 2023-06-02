#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to get the latest version of a module listed in go.mod
set -eu
if [[ $# -eq 0 ]]; then
    set -x
    go list -mod=mod -u -m all
    set +x
else
    for module in ${@}; do
        module=$(grep $module go.mod | xargs | cut -d" " -f1)
        go list -mod=mod -u -m $module
    done
fi
