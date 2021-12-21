#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Install kernel modules inside the mounted qemu image
## options
##       -c, --configuration <path> QEMU image configuration file
SUBDIRS=$1
IMG=/home/TMT/carlolo/workspace/qemu-vm-configs/21.04.img
DISK=/dev/sda3
MOUNTPOINT=/mnt/qemu-image-mount
set -u

# Check if the current working directory is the right one (TBD)

# Mount QEMU image
[[ ! -d $MOUNTPOINT ]] && sudo mkdir -pv $MOUNTPOINT
set -x
sudo guestmount --add $IMG --mount $DISK $MOUNTPOINT || exit 1

# Check whether the image has the appropriate destination directory (TBD)

if [[ ! -z $SUBDIRS ]]; then
    SUBDIRS="M=$SUBDIRS"
fi
# Build modules
make $SUBDIRS modules

# Install kernel modules
sudo make $SUBDIRS INSTALL_MOD_PATH=$MOUNTPOINT modules_install

# Un-mount QEMU image
sudo guestunmount $MOUNTPOINT

