#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

# The ISO image of the OS to be installed
ISO_PATH=$1
# The disk IMG file to install the OS into
IMAGE_PATH=$2
MEM=4G
set -u

[[ ! -f ${ISO_PATH} ]] && echo "Could not find '${ISO_PATH}' OS image file" && exit 1
[[ ! -f ${IMAGE_PATH} ]] && echo "Could not find ${IMAGE_PATH} disk file" && exit 1

qemu-system-x86_64 -cdrom ${ISO_PATH} ${IMAGE_PATH} -m ${MEM} -enable-kvm
