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

NS_NAME=$(kubectl get ${resource} -A | \
    awk {'printf ("%s\t%s\n", $1, $2)'} | \
    fzf --header "Select ${resource}"  --header-lines=1 --layout reverse)
NS=$(echo ${NS_NAME} | awk {'print $1'})
NAME=$(echo ${NS_NAME} | awk {'print $2'})

if [[ ${action} == "logs" ]]; then
    cmd="kubectl ${action} ${NAME} -n ${NS} $options"
else
    cmd="kubectl ${action} ${resource} ${NAME} -n ${NS} $options"
fi

echo "$cmd"
eval "$cmd"
