#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
# This script runs QEMU using the ISO image (with the ISO image kernel)

ISO_PATH="$1"
MEM="4G"
VID=0x1bc7
PID=0x1040

[[ ! -f ${ISO_PATH} ]] && echo "Could not find ${ISO_PATH} disk file" && exit 1

# add shared folder
# -net nic -net user,smb=/mnt/qemu_shared

set -x
sudo qemu-system-x86_64 \
    ${ISO_PATH} \
    -M q35 \
    -smp 2 \
    -cpu host \
    -m ${MEM} \
    -enable-kvm \
    -usb -device usb-host,productid=0xd00d,vendorid=0x18d1 \
    -usb -device usb-host,productid=$PID,vendorid=$VID
