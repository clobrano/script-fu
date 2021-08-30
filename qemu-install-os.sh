#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

local ISO_PATH=$1
local IMAGE_PATH=$2
local MEM=4G

[[ ! -f ${ISO_PATH} ]] && echo "Could not find '${ISO_PATH}' OS image file" && exit 1
[[ ! -f ${IMAGE_PATH} ]] && echo "Could not find ${IMAGE_PATH} disk file" && exit 1

qemu-system-x86_64 -cdrom ${ISO_PATH} ${IMAGE_PATH} -m ${MEM} -enable-kvm
