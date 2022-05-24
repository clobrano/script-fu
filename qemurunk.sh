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
shift
shift
# VENDOR,PRODUCT ID pairs to pass to the VM in the format "0xABCD:0xEFGH 0xILMN:0xOPQR ..."
USB_ID_LIST=( "$@" )
usbpassthroug=""
for id in "${USB_ID_LIST[@]}"; do
    echo $id
    VID=`echo $id | cut -d":" -f1`
    PID=`echo $id | cut -d":" -f2`
    usbpassthroug+="-usb -device usb-host,vendorid=$VID,productid=$PID "
done

set -x
sudo qemu-system-x86_64 \
    -pidfile /tmp/qemu.pid \
    -enable-kvm \
    -drive file=$DISK \
    -m $RAM \
    -kernel $KERNEL \
    -net user,hostfwd=tcp::2222-:22 \
    -net nic \
    -append "root=/dev/sda3 console=ttyS0 rw" \
    -serial mon:stdio \
    -display none \
    $usbpassthroug
set +x

