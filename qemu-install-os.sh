#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Call qemu to install an ISO image into a IMG disk
## options
##      -d, --disk <path>  Path to the IMG file (see qemu-create-image.sh)
##      -i, --iso <path> Path to the ISO file

# CLInt GENERATED_CODE: start

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--disk") set -- "$@" "-d";;
"--iso") set -- "$@" "-i";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hd:i:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        d) _disk=$OPTARG ;;
        i) _iso=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end


MEM=4G
set -u

[[ ! -f ${_iso} ]] && echo "Could not find '${_iso}' OS image file" && exit 1
[[ ! -f ${_disk} ]] && echo "Could not find ${_disk} disk file" && exit 1

qemu-system-x86_64 -cdrom ${_iso} ${_disk} -m ${MEM} -enable-kvm
