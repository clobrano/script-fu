#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to streamline gtk/gnome-shell communitheme build and install
## options:
##      -d, --dotfiles <path>   path to dotfiles folders [default: ~/dotfiles]
##      -p, --project <path>   path yaru folders [default: ~/workspace/yaru]

# GENERATED_CODE: start
# Default values
_dotfiles=~/dotfiles
_project=~/workspace/yaru

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--dotfiles") set -- "$@" "-d";;
"--project") set -- "$@" "-p";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hd:p:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        d) _dotfiles=$OPTARG ;;
        p) _project=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# GENERATED_CODE: end


_cmd="$_dotfiles/vim/vim/snippets/communitheme.py"

set -xe
python "$_cmd" "$_project" && echo "ALT-F2 + rt"
