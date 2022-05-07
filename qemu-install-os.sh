#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Call qemu to install an ISO image into a IMG disk
## options
##      -d, --disk <path>  Path to the IMG file (see qemu-create-image.sh)
##      -i, --iso <path>   Path to the ISO file
##      -a, --arch <name>  Architecture to use [default: x86_64]
##      -m, --mem <memory> Memory size [default: 4G]

# CLInt GENERATED_CODE: start
# info: https://github.com/clobrano/CLInt.git
# Default values
_arch=x86_64
_mem=4G

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--disk") set -- "$@" "-d";;
"--iso") set -- "$@" "-i";;
"--arch") set -- "$@" "-a";;
"--mem") set -- "$@" "-m";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hd:i:a:m:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        d) _disk=$OPTARG ;;
        i) _iso=$OPTARG ;;
        a) _arch=$OPTARG ;;
        m) _mem=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end

set -u

[[ ! -f ${_iso} ]] && echo "Could not find '${_iso}' OS image file" && exit 1
[[ ! -f ${_disk} ]] && echo "Could not find ${_disk} disk file" && exit 1

if [[ ${_arch} == "aarch64" ]]; then
    # https://futurewei-cloud.github.io/ARM-Datacenter/qemu/how-to-launch-aarch64-vm/
    set -e
    if [[ ! -f flash1.img ]]; then
        dd if=/dev/zero of=flash1.img bs=1M count=64
        dd if=/dev/zero of=flash0.img bs=1M count=64
        dd if=/usr/share/qemu-efi-aarch64/QEMU_EFI.fd of=flash0.img conv=notrunc
    fi

    qemu-system-aarch64 -nographic -machine virt,gic-version=max -m 512M -cpu max -smp 4 \
        -netdev user,id=vnet,hostfwd=:127.0.0.1:0-:22 -device virtio-net-pci,netdev=vnet \
        -drive file=${_disk},if=none,id=drive0,cache=writeback -device virtio-blk,drive=drive0,bootindex=0 \
        -drive file=${_iso},if=none,id=drive1,cache=writeback -device virtio-blk,drive=drive1,bootindex=1 \
        -drive file=flash0.img,format=raw,if=pflash -drive file=flash1.img,format=raw,if=pflash 
else
    qemu-system-${_arch} -cdrom ${_iso} ${_disk} -m ${_mem} -enable-kvm
fi

