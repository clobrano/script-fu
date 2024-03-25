#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## when-done waits for a process to end, then notifies the user.
## You can choose which process to wait for by passing a query as an argument.
## If no query is passed, you will be prompted to select a process.
## If multiple processes match the query, you will be prompted to select one.
## The notification is done by printing a message to the terminal, or by sending a message to ntfy.
## options:
##   -q, --query <query>  query to select the process to wait for
##   -l, --local          send a local notification when the process ends (via notify-send)
##   -r, --remote         send a remote notification when the process ends (via ntfy)

# CLInt GENERATED_CODE: start
# info: https://github.com/clobrano/CLInt.git

# CLInt GENERATED_CODE: start
# info: https://github.com/clobrano/CLInt.git

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--query") set -- "$@" "-q";;
"--local") set -- "$@" "-l";;
"--remote") set -- "$@" "-r";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hlrq:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        l) _local=1 ;;
        r) _remote=1 ;;
        q) _query=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end


res=$(pgrep ${_query:-""} | xargs -I {} sh -c 'tr "\\0" " " < /proc/{}/cmdline; echo ""' | fzf \
    --header $'Press ENTER to select the process' \
    --layout=reverse --info=inline --no-multi \
    --prompt 'Search >' --preview-window hidden:wrap)

if [[ $res == "" ]]; then
    echo "No process selected"
    exit 1
fi

pids=( $(pgrep "${query}") )
for i in ${!pids[@]}; do
    pid=${pids[$i]}
    cmd=$(cat /proc/${pid}/cmdline | sed -e "s/\x00/ /g"; echo)
    if [[ ${cmd} == ${res} ]]; then
        echo -e "Let's wait for ${pid}: \e[4m${cmd}\e[0m to end"
        tail --pid=${pid} --follow /dev/null
        break
    fi
done

[[ -n ${_local} ]] && notify-send -i "info" "Process ${_query} done"
[[ -n ${_remote} ]] && ntfy-send.sh "Process ${_query} done"
