#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Productive time is a script in my tmux configuration
## it is intended to show on tmux the count down to the time
## set in $HOME/.productive-time-deadline, and it is used (by me)
## as reminder that the time to do *SOMETHING IMPORTANT* is limited.
## This script is an helper to let me configure such file in an easier wan
## possibly with some intelligence and natural language processing converting time.

## options
##    <time>        Set new timer (e.g. 10:00, + 1 hour, ...)
##    -g, --get     Get current timer

# CLInt GENERATED_CODE: start

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--get") set -- "$@" "-g";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hgs:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        g) _get=1 ;;
        s) _set=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end

message=$@

if [[ -n $_get ]]; then
    cat $HOME/.productive-time-deadline
    exit 0
fi
result=`date --date="${message}" +%H:%M`
echo [+] setting the deadline to $result. Continue? [ENTER/CTRL-c]
read
echo $result > $HOME/.productive-time-deadline
