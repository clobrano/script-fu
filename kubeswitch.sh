#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## kubeswitch is a script to switch between kubeconfig files.
## The script expects the following:
## 1. ~/.kube/config is just a symlink to the current kubeconfig file (see NOTE below)
## 2. ~/.kube folder contains all the real kubeconfig files with a consistent name
## 
## Given the above, kubeswitch shows you the current kubeconfig, the available
## choices and changes the symlinks for you
## 
## NOTE
## kubeswitch does not want to break any configuration, so it checks if
## ~/.kube/config is a symlink already, and if not, it proposes to back it up for
## you with a name of your choice before moving on.
##
## usage:
##     kubeswith.sh          Show the prompt to select a kubeconfig file
##     kubeswith.sh --delete Show the prompt to delete a kubeconfig file
##
## options:
##  -d, --delete          Show the prompt to delete a kubeconfig files


# CLInt GENERATED_CODE: start
# info: https://github.com/clobrano/CLInt.git

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--delete") set -- "$@" "-d";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hd' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        d) _delete=1 ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end

# FUNCTIONS
check_config_is_simlink() {
if [[ ! -L ~/.kube/config ]]; then
    echo "[!] ~/.kube/config is NOT a symlink now! Creating a symlink will break current config"
    echo -n "    \e4[press ENTER\e[0m"
    echo " to back it up with another name, CTRL-C otherwise"
    read
    echo "[+] enter the backup file name (it will be stored inside ~/.kube folder)"
    read config_bk_name
    mv ~/.kube/config ~/.kube/$config_bk_name
fi
}
show_current() {
    if [[ -e ~/.kube/config ]]; then
        echo "Currently using `readlink ~/.kube/config`"
    fi
}

count_configs() {
    return "${#config_array[@]}"
}

show_prompt() {
    echo "[+] the other available kube/configs are:"
    let i=0
    for config in "${config_array[@]}"; do
        echo "  $i -> $config"
        let i=$i+1
    done
}

set_kube_map() {
    config=$1
    # config's name has format "dsal-<OCP-version>_<hostname>"
    # so here we are interested in the second part
    hostname=$(echo ${config} | awk -F"_" '{print $2}')
    tmp=$(mktemp)
    # jq does not edit file in-place
    jq --arg a "${hostname}" '.current = $a' $KUBE_MAP > $tmp && mv $tmp $KUBE_MAP
}


# MAIN
trap "echo [+] script interrupted, nothing to do; exit" SIGINT 
check_config_is_simlink

if [[ -n $_delete ]]; then
    ACTION="DELETE"
else
    ACTION="USE"
fi
PROMPT+="Select kubeconfig file to $ACTION: "

selection=$(ls ~/.kube | grep -vE "^config$|dsal-host" | grep -v cache | \
    fzf --layout=reverse --header="$(show_current)" --prompt="$PROMPT")
if [[ -z $selection ]]; then
    echo "[+] nothing selected, exiting"
    exit 0
fi

if [[ -n $_delete ]]; then
    read -p "[+] deleting $selection [Press ENTER to continue, CTRL-C to abort]"
    rm ~/.kube/${selection}
else
    set -x
    ln -sf ~/.kube/${selection} ~/.kube/config || echo "[!] something went wrong"
fi
