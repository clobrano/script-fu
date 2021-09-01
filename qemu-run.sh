#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to run QEMU images from configuration file
[[ -z $1 ]] && echo "[!] configuration file missing. Usage> qemu-run.sh configuration.conf" && exit 1
CONF=$1

ARCH=`grep "ARCH=" "$CONF" | cut -d"=" -f2`
ARCH=${ARCH:-"x86_64"}

BZIMAGE=`grep "BZIMAGE=" "$CONF" | cut -d"=" -f2`
IMG=`grep "IMG=" "$CONF" | cut -d"=" -f2`

RAM=`grep "RAM=" "$CONF" | cut -d"=" -f2`
RAM=${RAM:-"2G"}

SSHPORTNO=`grep "SSHPORTNO=" "$CONF" | cut -d"=" -f2`
SSHPORTNO=${SSHPORTNO:-2222}

HEADLESS=`grep "HEADLESS=" "$CONF" | cut -d"=" -f2`
HEADLESS=${HEADLESS:-"false"}

USBPASSTHROUGH=`grep "USBPASSTHROUGH=" "$CONF" | cut -d"=" -f2`
USBPASSTHROUGH=${USBPASSTHROUGH:-""}


# Build usb passthrough configuration
usbpassthroug=""
for id in `echo $USBPASSTHROUGH`; do
    VID=`echo $id | cut -d":" -f1`
    PID=`echo $id | cut -d":" -f2`
    usbpassthroug+="-usb -device usb-host,vendorid=$VID,productid=$PID "
done

if [[ "$HEADLESS" = "true" ]]; then
    set -xu
    sudo qemu-system-$ARCH \
        -kernel $BZIMAGE \
        -append "root=/dev/sda5 console=ttyS0" -serial mon:stdio -display none \
        -hda $IMG \
        -m $RAM \
        -enable-kvm \
        -net nic -net user,hostfwd=tcp::$SSHPORTNO-:22 \
        $usbpassthroug   
else
    set -xu
    sudo qemu-system-$ARCH \
        -hda $IMG \
        -m ${RAM} \
        -enable-kvm \
        -M q35 \
        -smp 2 \
        -cpu host \
        -net nic -net user,hostfwd=tcp::$SSHPORTNO-:22 \
        $usbpassthroug
fi
