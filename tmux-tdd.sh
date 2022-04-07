#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to support showing TDD results on TMUX (see tdd-spy.sh)
##      -n, --name <name>        Project name [default: ""]
##      -r, --run <commandline>  The commandline to run TDD for the given project
##      -c, --clean              Clean TDD status
##
## Currently this script expects the output of the tdd suite to print "FAIL" only
## in case of failures.

# CLInt GENERATED_CODE: start
# Default values
_name=""

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--name") set -- "$@" "-n";;
"--run") set -- "$@" "-r";;
"--clean") set -- "$@" "-c";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hcn:r:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        c) _clean=1 ;;
        n) _name=$OPTARG ;;
        r) _run=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end
if [[ ! -z $_clean ]]; then
    echo "" > ${HOME}/.tdd-result
    exit 0
fi

if [[ ! -z $_run ]]; then
    when=$(date +%H:%M.%S)
    echo "$_name TDD running [$when]" > ${HOME}/.tdd-result
    #out=$(${_run})
    ${_run} | tee /tmp/tdd-running.log
    if [[ $? != 0 ]]; then
        echo "$_name TDD error [$when]" > ${HOME}/.tdd-result
    fi
    failures=$(cat /tmp/tdd-running.log  | grep -c FAIL)
    when=$(date +%H:%M.%S)
    if [[ $failures -gt 0 ]]; then
        echo "$_name TDD Fail [$when]" > ${HOME}/.tdd-result
    else
        echo "$_name TDD OK [$when]" > ${HOME}/.tdd-result
    fi
    exit 0
fi

echo "[!] either use --run or --clean flag!"
exit 1
