#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## SSH connection with password
## options
## -u, --user <string> username [default: carlolo]
## -a, --address <ip>
## -s, --source <path>
## -d, --destination <path>
# GENERATED_CODE: start
# Default values
_user=carlolo

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--user") set -- "$@" "-u";;
"--address") set -- "$@" "-a";;
"--source") set -- "$@" "-s";;
"--destination") set -- "$@" "-d";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hu:a:s:d:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        u) _user=$OPTARG ;;
        a) _address=$OPTARG ;;
        s) _source=$OPTARG ;;
        d) _destination=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# GENERATED_CODE: end


set -x
scp -o PreferredAuthentications=password -o PubkeyAuthentication=no "$_source" $_user@$_address:"$_destination"
