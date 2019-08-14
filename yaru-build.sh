#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to streamline gtk/gnome-shell communitheme build and install
## options:
##      -p, --project <path>   path yaru folders [default: ~/workspace/yaru]

# CLInt GENERATED_CODE: start
# Default values
_project=~/workspace/yaru

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--project") set -- "$@" "-p";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hp:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        p) _project=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end

set -xe
if [ ! -d  "$_project/build" ]; then
    cwd=`pwd`
    cd "$_project"
    meson build
    cd "$cwd"
fi

sudo -i -H ninja install -C "$_project/build"
theme-toggle.sh
