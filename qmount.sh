#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Mount QCOW image with qemu-nbd
## options
##    -d, --disk <path>  Path to disk image
##    -i, --id <number>  Number of the partition to be mounted

# CLInt GENERATED_CODE: start
# info: https://github.com/clobrano/CLInt.git

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--disk") set -- "$@" "-d";;
"--id") set -- "$@" "-i";;
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
        i) _id=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end

set -xu

MOUNT_DIR=/mnt/qemu_nbd_mnt
if [[ ! -d $MOUNT_DIR ]]; then
    echo [+] creating mount directory $MOUNT_DIR
    sudo mkdir -pv $MOUNT_DIR
fi

# check nbd driver is loaded
if ! lsmod | grep nbd >/dev/null; then
    echo [+] mounting nbd kernel module
    sudo modprobe nbd max_part=8
fi
# check if partition is already mounted
if mount -l | grep /dev/nbd0p$_id >/dev/null;then
    echo [!] Partition $_id is already mounted
    exit 0
else
    # connect and mount
    sudo qemu-nbd --connect=/dev/nbd0 $_disk
    sudo mount /dev/nbd0p$_id $MOUNT_DIR
fi
