#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Simple and lazy script to write NEOVIM draft in a configurable folder
## options
##   -t, --topic <name>      Name of the draft. It will be used as file name
##   -f, --folder <path>     Path to the folder that will contain the draft folder [default: ~]
##   -l, --list              List drafts in draft folder
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
"--list") set -- "$@" "-l";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hlt:f:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        l) _list=1 ;;
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


[ ! -z $_list ] && ls ${_folder}/drafts && exit 0

set -eu
[ ! -d ${_folder}/drafts ] && mkdir ${_folder}/drafts

file=${_folder}/drafts/$_topic.md
if [ -f "$file" ]; then
    echo "$file" exists already
else
    echo "# $_topic" >> "$file"
fi
xdg-open "$file"

