#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
#
## options
##     -m, --message <text> Content
##     -l, --local  Desktop notification
##     -r, --remote Mobile notification


# CLInt GENERATED_CODE: start
# info: https://github.com/clobrano/CLInt.git

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--message") set -- "$@" "-m";;
"--local") set -- "$@" "-l";;
"--remote") set -- "$@" "-r";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hlrm:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        l) _local=1 ;;
        r) _remote=1 ;;
        m) _message=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end

[[ -n ${_local} ]] && notify-send -i "info" "${_message}"
[[ -n ${_remote} ]] && ntfy-send.sh "${_message}"
