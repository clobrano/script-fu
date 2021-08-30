#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
NEW_IMAGE_PATH=$1
IMAGE_SZ=$2

[[ ! -d $(dirname ${NEW_IMAGE_PATH}) ]] && echo "$(dirname ${NEW_IMAGE_PATH}) directory does not exist" && exit 1
[[ -f ${NEW_IMAGE_PATH} ]] && echo "${NEW_IMAGE_PATH} image already exists" && return

qemu-img create -f qcow2 ${NEW_IMAGE_PATH} $IMAGE_SZ
