#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Wrapper script round kubectl that uses fzf [1] to select target resource without the need to
## provide name or namespace manually.
## 
## usage:
##      $ kk <kind> [--namespace <namespace> --selector <selector> ]
## 
## or just
##      $ kk
## 
## to select one of the 10 last commands run by kk
## 
## kk works in three stesp:
## 1. Get all the cluster resources of <kind> (or the ones under --namespace if provided) and let
##    you fuzzy search a specific one, getting its name, and namespace if any.
## 2. Select one of the usual kubectl verbs (get, logs, describe, ...) and compose the command line
## 3. Give you a chance to edit the command line, adding more flags or, e.g., pipe the result to
##    another program.
## 
## The final command line is executed and stored under $HOME/.kk.lastcommands together with the
## last 10 unique commands issued.
## 
## options:
##      -n, --namespace <namespace> The namespace into which kk will look for the resources [default: --all-namespaces]
##      -s, --selector <selector>   Selector (label query) to filter on
##      -c, --clean                 Clean $HOME/.kk.lastcommands history

# get the positional arguments first
kind=$1
shift

# then parse flags


# CLInt GENERATED_CODE: start
# info: https://github.com/clobrano/CLInt.git
# Default values
_namespace=--all-namespaces

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--namespace") set -- "$@" "-n";;
"--selector") set -- "$@" "-s";;
"--clean") set -- "$@" "-c";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hcn:s:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        c) _clean=1 ;;
        n) _namespace=$OPTARG ;;
        s) _selector=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end


KK_LASTCMDS=$HOME/.kk.lastcommands

if [[ -n ${_clean} ]]; then
    echo > ${KK_LASTCMDS}
    exit 0
fi

if [[ -z ${kind} ]]; then
    echo "[+] repeating command from history (${KK_LASTCMDS}) "
    cmd=$(cat ${KK_LASTCMDS} | \
        fzf --prompt "Search and Select: " \
            --header=$'You can edit the command after selection\n\n' \
            --border \
            --layout=reverse \
            --height=70% )
else
    if [[ ${_namespace} = "--all-namespaces" ]]; then
        NN=${_namespace}
    else
        NN="--namespace ${_namespace}"
    fi

    if [[ -n ${_selector} ]]; then
        SELECTOR="--selector ${_selector}"
    else
        _selector="empty"
        SELECTOR=""
    fi

    # Get the resource's info first
    RESOURCE_INFO=$(kubectl get ${kind} ${NN} ${SELECTOR} -o wide | \
        fzf --prompt "Search and Select ${kind} under ${_namespace} Namespace and ${_selector} selector: " \
        --header=$'Press CTRL-R to reload\n\n' \
        --header-lines=1 \
        --border \
        --preview='echo {}' \
        --preview-window=up:3:wrap \
        --layout=reverse \
            --height=70% \
        --bind "ctrl-r:reload(kubectl get ${kind} ${NN} ${SELECTOR} -o wide)"
        )

    if [[ -z ${RESOURCE_INFO} ]]; then
        exit 0
    fi

    # Get NAME from resources that do not have namespace
    if [[ ${kind} =~ "node" ]] || [[ ${kind} == "crd"  ]] || [[ ${kind} =~ "clusterrole"  ]]; then
        NAME=$(echo ${RESOURCE_INFO} | awk {'print $1'})
    else
        # Get NAME and NS from the others
        NS=$(echo ${RESOURCE_INFO} | awk {'print $1'})
        NAME=$(echo ${RESOURCE_INFO} | awk {'print $2'})
    fi


    # Select the action via FZF (get, logs, describe, explain, edit, delete)
    action=$(echo -e "get\nlogs\ndescribe\nexplain\nedit\ndelete" | \
        fzf --prompt "Select the action: " \
            --layout=reverse --height=70% \
            --border)

    if [[ ${action} == "logs" ]]; then
            cmd="kubectl logs ${NAME} -n ${NS}"
    else
        if [[ -n ${NS} ]]; then
            cmd="kubectl ${action} ${kind} ${NAME} -n ${NS}"
        else
            cmd="kubectl ${action} ${kind} ${NAME}"
        fi
    fi
fi

echo "executing: $cmd"
echo -n "[+] Edit the command before execute (y/n)? "
read res
if [[ ${res} == "y" ]]; then
    if [[ -z $EDITOR ]]; then
        set -e
        echo "[!] EDITOR environment variable not found. Trying with vim"
        EDITOR=vim
    fi
    echo $cmd > /tmp/kk.lastcommand
    $EDITOR /tmp/kk.lastcommand
    cmd=$(cat /tmp/kk.lastcommand)
fi

[[ -z ${cmd} ]] && exit 0

echo "executing: $cmd"
echo "$cmd" >> ${KK_LASTCMDS}
eval "$cmd"
# Only keep the last unique 10 commands in KK_LASTCMDS file
tac ${KK_LASTCMDS} | uniq -u | head -10 > ${KK_LASTCMDS}.tmp
cat ${KK_LASTCMDS}.tmp > ${KK_LASTCMDS}
echo "[+] $(cat ${KK_LASTCMDS} | wc -l) last commands available in ${KK_LASTCMDS}"
