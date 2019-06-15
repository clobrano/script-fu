#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Simple interface to `at` to simplify the usage as pomodoro timer.
## usage:
##    pomo.sh --work [--description <task description>] [-t <time>]
##    pomo.sh --pause [-t <time>]
##    pomo.sh --info
##    pomo.sh --stop
## options:
##    -w, --work
##    -d, --description <message> [default: "working..."]
##    -p, --pause
##    -i, --info
##    -s, --stop
##    -t, --time           default 25 for work and 5 for pause
# GENERATED_CODE: start
# Default values
_description="working..."

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--work") set -- "$@" "-w";;
"--description") set -- "$@" "-d";;
"--pause") set -- "$@" "-p";;
"--info") set -- "$@" "-i";;
"--stop") set -- "$@" "-s";;
"--time") set -- "$@" "-t";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hwpistd:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        w) _work=1 ;;
        p) _pause=1 ;;
        i) _info=1 ;;
        s) _stop=1 ;;
        t) _time=1 ;;
        d) _description=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# GENERATED_CODE: end

set -e
which at 2>&1>/dev/null
which notify-send 2>&1>/dev/null

if [ $_work ]; then
    time=${_time:-25}
    echo "notify-send -i time -c urgent $_description" | at now + $time min
fi

if [ $_pause ]; then
    time=${_time:-5}
    echo "notify-send -i time -c urgent 'pause finished'" | at now + $time min
fi

if [ $_info ]; then
    atq
fi

if [ $_stop ]; then
    atq
fi
