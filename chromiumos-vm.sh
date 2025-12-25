#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## This script manages a ChromiumOS virtual machine, allowing for starting, stopping, and configuring its network and memory settings.
IMAGE=${1}
KILL=${2:-""}
MEM="4G"
NET="10.0.2.0/27"
SSHPORT=9222
PIDFILE=/tmp/qemu_$SSHPORT.pid

set -eu

if [[ ${KILL} == "-k" ]]; then
    PID=`sudo cat $PIDFILE`
    echo "Killing QEMU $PID"
    sudo kill $PID
else
sudo qemu-system-x86_64 \
    -pidfile $PIDFILE \
    -m $MEM \
    -smp 4 \
    -vga virtio \
    -daemonize \
    -cpu SandyBridge,-invpcid,-tsc-deadline,check,vmx=on \
    -usb -device usb-tablet \
    -device virtio-scsi-pci,id=scsi \
    -device virtio-rng \
    -device scsi-hd,drive=hd \
    -drive if=none,id=hd,file=${IMAGE},cache=unsafe,format=raw \
    -usb -device usb-host,vendorid=0x1bc7,productid=0x1041 \
    -net nic \
    -net user,hostfwd=tcp::$SSHPORT-:22 \
    -display vnc=127.0.0.1:0 \
    -enable-kvm

echo QEMU running with PID $(sudo cat $PIDFILE)
fi
