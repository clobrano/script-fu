#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to streamline gtk/gnome-shell communitheme build and install
## options:
##      -p, --project <name>    either gtk or shell (this is mapped to the folder name, so if you change default folders' names, this won't work anymore)
##      -d, --dotfiles <path>   path to dotfiles folders [default: ~/dotfiles]

# GENERATED_CODE: start
# Default values
_dotfiles=~/dotfiles

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--project") set -- "$@" "-p";;
"--dotfiles") set -- "$@" "-d";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hp:d:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        p) _project=$OPTARG ;;
        d) _dotfiles=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# GENERATED_CODE: end

_cmd="$_dotfiles/vim/vim/snippets/communitheme.py"

set -x
[ "$_project" = "gtk" ] && python "$_cmd" gtk-communitheme && theme-refresh.sh
[ "$_project" = "shell" ] && python "$_cmd" gnome-shell-communitheme && echo "ALT-F2 + rt"
