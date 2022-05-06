#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to support showing TDD results on TMUX (see tdd-spy.sh)
##      -n, --name <name>        Project name [default: ""]
##      -r, --run <commandline>  The commandline to run TDD for the given project
##      -c, --clean              Clean TDD status
##      -t, --type <name>        Type of unittest runner (meson, pytest) [default: "meson"]
##
## Currently this script expects the output of the tdd suite to print "FAIL" only
## in case of failures.

# CLInt GENERATED_CODE: start
# Default values
_name=""
_type="meson"

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--name") set -- "$@" "-n";;
"--run") set -- "$@" "-r";;
"--clean") set -- "$@" "-c";;
"--type") set -- "$@" "-t";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hcn:r:t:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        c) _clean=1 ;;
        n) _name=$OPTARG ;;
        r) _run=$OPTARG ;;
        t) _type=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end

count_failures() {
    local log=$1
    local type=${_type:-"meson"}
    if [[ $type = "meson" ]]; then
        failures=$(cat $log | grep -c -e FAIL -e "ninja: build stopped")
    fi
    if [[ $type = "pytest" ]]; then
        failures=$(cat $log | grep -c -e FAILED -e ERROR)
    fi
    if [[ $type = "cpputest" ]]; then
        failures=$(cat $log | grep -c -e FAILED -e Errors)
    fi
    echo $failures
}

if [[ ! -z $_clean ]]; then
    echo "" > ${HOME}/.tdd-result
    exit 0
fi

if [[ ! -z $_run ]]; then
    when=$(date +%H:%M.%S)
    echo "$when $_name test ⏳ " > ${HOME}/.tdd-result
    ${_run} 2>&1 | tee /tmp/tdd-running.log
    retcode=${PIPESTATUS[0]}
    if [[ $retcode -gt 0 ]]; then
        echo "$when $_name test ⛔ " > ${HOME}/.tdd-result
        exit 1
    fi
    when=$(date +%H:%M.%S)
    failures=$(count_failures /tmp/tdd-running.log)
    if [[ $failures -gt 0 ]]; then
        echo "$when $_name test ⛔ " > ${HOME}/.tdd-result
        retcode=1
    else
        echo "$when $_name test ✅ " > ${HOME}/.tdd-result
        retcode=0
    fi
    exit $retcode
fi

echo "[!] either use --run or --clean flag!"
exit 1
