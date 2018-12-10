#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Simple and lazy script to write NEOVIM draft in $HOME/.drafts folder
## options
##   -t, --topic <name>      Name of the draft. It will be used as file name
##   -f, --folder <path>     Path to the folder that will contain the draft folder [default: ~]
# GENERATED_CODE: start
# Default values
_folder=~

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--topic") set -- "$@" "-t";;
"--folder") set -- "$@" "-f";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'ht:f:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        t) _topic=$OPTARG ;;
        f) _folder=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# GENERATED_CODE: end

set -eu


[ ! -d ${_folder}/.drafts ] && mkdir ${_folder}/.drafts

file=${_folder}/.drafts/$_topic.md
[ ! -f "$file" ] && echo "# $_topic" > $file
nvim -c "Writer" ${_folder}/.drafts/$_topic.md

