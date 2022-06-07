#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

DISK=$1

qemu-system-aarch64 \
    -pidfile /tmp/qemu.pid \
    -nographic \
    -machine virt,gic-version=max -m 1G -cpu max -smp 4 \
    -net user,hostfwd=tcp::2222-:22 -net nic\
    -netdev user,id=vnet,hostfwd=:127.0.0.1:0-:22 -device virtio-net-pci,netdev=vnet \
    -drive file=${DISK},if=none,id=drive0,cache=writeback \
        -device virtio-blk,drive=drive0,bootindex=0 \
    -drive file=flash0.img,format=raw,if=pflash -drive file=flash1.img,format=raw,if=pflash 
