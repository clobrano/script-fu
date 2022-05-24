#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Un-mount QCOW image with qemu-nbd
MOUNT_DIR=/mnt/qemu_nbd_mnt
if [[ ! -d  $MOUNT_DIR ]]; then
    echo [!] not mount directory $MOUNT_DIR. Nothing to do
    exit 1
fi
sudo umount $MOUNT_DIR
sudo qemu-nbd --disconnect /dev/nbd0
