#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
# This script runs QEMU using the ISO image AND a custom Kernel (bzImage)
# NOTES
# - -append "root=/dev/sda5" -> I found the right sda partition via try and error.
#                               In case of error the kernel reports the available
#                               partitions, and I tried them all

# The bzImage path
KERNEL="$1"
# The QEMU image with installed OS, or at least a rootfs
DISK="$2"
RAM=4G
VID="0x1bc7"
PID="0x1040"

set -x
sudo qemu-system-x86_64 \
    -enable-kvm \
    -hda $DISK \
    -m $RAM \
    -kernel $KERNEL \
    -append "root=/dev/sda5 console=ttyS0 rw" \
    -net nic -net user,hostfwd=tcp::2222-:22 \
    -serial stdio \
    -display none \
    -usb -device usb-host,vendorid=$VID,productid=$PID
set +x

