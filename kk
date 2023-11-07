#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## This script simplify kubectl commands by using fzf to select target resources.
## The script will fuzzy-find the resource in the global namespace, then it will use the
## selected resource to find the appropriate namespace.
## 
## positional arguments:
##   action               kubectl action (e.g. logs, describe)
##   resource             kubectl resource (e.g. pod, deployment)
##   options              kubectl options (e.g. -o, -f)
##
## examples:
##   kk describe pod
##   kk logs pod "-f"
##   kk get pod "-o yaml"

if [[ $# -lt 2 ]]; then
    echo "Usage: kk <action> <resource> [options]"
    exit 1
fi

action=$1
shift
resource=$1
shift
options="$@"



if [[ ${action} == "get" ]] && [[ ${resource} == "event" ]]; then
    # Let FZF filter over all event's data
    HEADER=
    selections=$(kubectl get event -A | \
        fzf --header=$'Press TAB to select multiple events, then ENTER to show them all together\nPress CTRL-R to reload\n\n' \
            --prompt "Search ${resource}: " \
            --preview="echo {}" \
            --header-lines=1 \
            --preview-window=up:3:wrap \
            --layout=reverse \
                --height=70% \
            --multi \
            --bind "ctrl-r:reload(kubectl get ${resource} -A -o wide)"
        )
    echo -en "$selections"
    exit 0
fi

NS_NAME=$(kubectl get ${resource} -A -o wide | \
    fzf --prompt "Search/Select ${resource}: " \
    --header=$'Press CTRL-R to reload\n\n' \
    --header-lines=1 \
    --preview='echo {}' \
    --preview-window=up:3:wrap \
    --layout=reverse \
        --height=70% \
    --bind "ctrl-r:reload(kubectl get ${resource} -A -o wide)"
    )

if [[ ${resource} =~ "node" ]]; then
    NAME=$(echo ${NS_NAME} | awk {'print $1'})
    cmd="kubectl ${action} ${resource} ${NAME} $options"
else
    NS=$(echo ${NS_NAME} | awk {'print $1'})
    NAME=$(echo ${NS_NAME} | awk {'print $2'})
    if [[ ${action} == "logs" ]]; then
        cmd="kubectl ${action} ${NAME} -n ${NS} $options"
    else
        cmd="kubectl ${action} ${resource} ${NAME} -n ${NS} $options"
    fi
fi

echo "$cmd" | xclip -selection clipboard
echo "$cmd"
eval "$cmd"
