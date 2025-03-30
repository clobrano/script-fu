#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## options
##     -c, --channel <string>   nfty channel (defaults to $NTFY_HANDLE environment variable)
##     -m, --message <message>  the message to include in the notification

# CLInt GENERATED_CODE: start
# info: https://github.com/clobrano/CLInt.git

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--channel") set -- "$@" "-c";;
"--message") set -- "$@" "-m";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo "[!] Unexpected flag in command line $*"
}

# Parsing flags and arguments
while getopts 'hc:m:' OPT; do
    case "$OPT" in
        h) sed -ne 's/^## \(.*\)/\1/p' "$0"
           exit 1 ;;
        c) _channel=$OPTARG ;;
        m) _message=$OPTARG ;;
        \?) print_illegal "$@" >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' "$0"
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end

if [ -z "$_channel" ]; then
    _channel="$NTFY_HANDLE"
fi

if [ -z "$_message" ]; then
    echo "[+] message arg is mandatory"
    $0 -h
    exit 1
fi

curl -d "$_message" ntfy.sh/"$_channel"
