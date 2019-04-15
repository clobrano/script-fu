#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## SSH connection with password
## options
## -u, --user <string> username [default: carlolo]
## -a, --address <ip> [default: 10.102.21.41]
# GENERATED_CODE: start
# Default values
_user=carlolo
_address=10.102.21.41

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--user") set -- "$@" "-u";;
"--address") set -- "$@" "-a";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hu:a:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        u) _user=$OPTARG ;;
        a) _address=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# GENERATED_CODE: end


ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no $_user@$_address
