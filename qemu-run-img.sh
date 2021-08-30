#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
# This script runs QEMU using the ISO image (with the ISO image kernel)

ISO_PATH="$1"
shift
MEM="4G"
# VENDOR,PRODUCT ID pairs to pass to the VM in the format "0xABCD:0xEFGH 0xILMN:0xOPQR ..."
USB_ID_LIST=( "$@" )
usbpassthroug=""
for id in "${USB_ID_LIST[@]}"; do
    echo $id
    VID=`echo $id | cut -d":" -f1`
    PID=`echo $id | cut -d":" -f2`
    usbpassthroug+="-usb -device usb-host,vendorid=$VID,productid=$PID "
done

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
    -net nic -net user,hostfwd=tcp::2222-:22 \
    -net nic \
    $usbpassthroug
