#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to record the screen using ffmpeg (and xandr)
## usage:
## options:
##      -f, --file <path>   Output file path
##      -d, --display <id>  Display to record [default: :0.0]

# GENERATED_CODE: start
# Default values
_display=:0.0

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--file") set -- "$@" "-f";;
"--display") set -- "$@" "-d";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hf:d:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        f) _file=$OPTARG ;;
        d) _display=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# GENERATED_CODE: end

size=$(xrandr | awk '/ connected/{print $4}' | cut -d'+' -f1)
set -xe
ffmpeg -f x11grab -s $size -i $_display $_file
