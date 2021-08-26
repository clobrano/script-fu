#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Create an image (img) file to use it with QEMU

image_create() {
    local fullpath=$1
    local size=$2
    local dir=/tmp/img-rootfs
    [[ ! -d $(dirname ${fullpath}) ]] && echo [!] destination directory '$(dirname ${fullpath}) does not exist' && exit 1
    [[ -f ${fullpath} ]] && echo [!] file '${fullpath} already exist' && exit 1
    cmd="qemu-img create ${fullpath} ${size}"
    echo $cmd
    $cmd
    [[ $? != "0" ]] && return 1

    cmd="mkfs.ext4 ${fullpath}"
    echo $cmd
    $cmd
    [[ $? != "0" ]] && return 1

    cmd="mkdir $dir"
    echo $cmd
    $cmd
    cmd="mount -o loop ${fullpath} $dir"
    echo $cmd
    sudo $cmd

    cmd="debootstrap --arch amd64 focal $dir"
    echo $cmd
    sudo $cmd

    echo "clean up"
    sudo umount $dir
    rm -r $dir
}

image_create $HOME/Downloads/jessie.img 1g
