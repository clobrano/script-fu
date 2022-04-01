#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
# This script runs QEMU aarch64 image (with the ISO image kernel)
IMG=$1

qemu-system-aarch64 -nographic -machine virt,gic-version=max -m 2G -cpu max -smp 4 \
    -netdev user,id=vnet,hostfwd=:127.0.0.1:0-:22 -device virtio-net-pci,netdev=vnet \
    -drive file=${IMG},if=none,id=drive0,cache=writeback -device virtio-blk,drive=drive0,bootindex=0 \
    -drive file=flash0.img,format=raw,if=pflash -drive file=flash1.img,format=raw,if=pflash
