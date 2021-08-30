#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

# The path to the disk IMG file to create (with .img extension)
NEW_IMAGE_PATH=$1
# The image size (e.g. 10G)
IMAGE_SZ=$2
set -u

[[ ! -d $(dirname ${NEW_IMAGE_PATH}) ]] && echo "$(dirname ${NEW_IMAGE_PATH}) directory does not exist" && exit 1
[[ -f ${NEW_IMAGE_PATH} ]] && echo "${NEW_IMAGE_PATH} image already exists" && return

qemu-img create -f qcow2 ${NEW_IMAGE_PATH} $IMAGE_SZ
