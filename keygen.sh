#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to speed up ssh keys generation for services like gitlab and github
## options
## -n, --name <string>      Private key name [default: id_rsa]
## -e, --email <string>     Email to associate with the key
# GENERATED_CODE: start
# Default values
_name=id_rsa

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--name") set -- "$@" "-n";;
"--email") set -- "$@" "-e";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hn:e:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        n) _name=$OPTARG ;;
        e) _email=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# GENERATED_CODE: end

set -xe

cd $HOME/.ssh

ssh-keygen -o -t rsa -b 4096 -C "$_email" -f $_name
ssh-add $_name
xclip -sel clip < $_name.pub

cd -

