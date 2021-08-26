#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to create, install and run QEMU based virtual system
## usage:
## options:
##    -c, --create           Create a disk image at the given path (needs --disk and --size)
##    -i, --install <path>   Install the given ISO image (needs --disk and --mem)
##    -r, --run              Run the VM in the given disk (needs --disk and --mem)
##    -d, --disk <path>      The path to the disk image
##    -s, --size <string>    The size of the disk image [default:16G]
##    -m, --mem <string>     The OS size [default:4G]
##    -v, --vid <number>     The USB vendor ID for USB passthrough
##    -p, --pid <number>     The USB product IDfor USB passthrough

# CLInt GENERATED_CODE: start
# Default values
_size=16G
_mem=4G

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--create") set -- "$@" "-c";;
"--install") set -- "$@" "-i";;
"--run") set -- "$@" "-r";;
"--disk") set -- "$@" "-d";;
"--size") set -- "$@" "-s";;
"--mem") set -- "$@" "-m";;
"--vid") set -- "$@" "-v";;
"--pid") set -- "$@" "-p";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hcri:d:s:m:v:p:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        c) _create=1 ;;
        r) _run=1 ;;
        i) _install=$OPTARG ;;
        d) _disk=$OPTARG ;;
        s) _size=$OPTARG ;;
        m) _mem=$OPTARG ;;
        v) _vid=$OPTARG ;;
        p) _pid=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end

DISK_IMG=$_disk
DISK_SZ=$_size
OS_FILE=$_install
OS_MEM=$_mem

USB_PASSTHROUGH_VID=$_vid
USB_PASSTHROUGH_PID=$_pid

create_qcow2_image() {
    local path=$1
    local size=$2
    [[ ! -d $(dirname ${path}) ]] && echo "$(dirname ${path}) directory does not exist" && exit 1
    [[ -f ${path} ]] && echo "${path} image already exists" && return
    cmd="qemu-img create -f qcow2 ${path} $size"
    echo $cmd
    $cmd
}

install_os() {
    local image_path=$1
    local disk_path=$2
    local mem=$3
    [[ ! -f ${image_path} ]] && echo "Could not find '${image_path}' OS image file" && exit 1
    [[ ! -f ${disk_path} ]] && echo "Could not find ${disk_path} disk file" && exit 1
    cmd="qemu-system-x86_64 -cdrom ${image_path} ${disk_path} -m ${mem} -enable-kvm"
    echo $cmd
    $cmd
}

install_os_headless() {
    local name=$1
    local iso=$2
    local disk=$3
    local vcpus=2
    cmd="virt-install \
        --virt-type=kvm \
        --name $name \
        --ram $_mem \
        --vcpus=$vcpus \
        --os-variant=$name \
        --hvm \
        --location=$iso \
        --network network=default,model=virtio \
        --disk path=$disk/$name.img,size=$_size,bus=virtio"
    echo $cmd
    sudo $cmd
}

run_os() {
    local disk_path=$1
    local mem=$2
    local usb_passthrough=""
    set -u
    [[ ! -f ${disk_path} ]] && echo "Could not find ${disk_path} disk file" && exit 1
    if [[ -n $USB_PASSTHROUGH_VID ]] && [[ -n $USB_PASSTHROUGH_PID ]]; then
        usb_passthrough="-usb -device usb-host,productid=$USB_PASSTHROUGH_PID,vendorid=$USB_PASSTHROUGH_VID"
    fi
    cmd="qemu-system-x86_64 \
        ${disk_path} \
        -M q35 \
        -smp 2 \
        -cpu host \
        -m ${mem} \
        -enable-kvm \
        -net nic -net user,smb=/mnt/qemu_shared \
        -usb -device usb-host,productid=0xd00d,vendorid=0x18d1 \
        $usb_passthrough"
    echo $cmd
    sudo $cmd
}

run_os_host_kernel() {
    local img=$1
    local mem=$2
    local usb_passthrough=""
    [[ ! -f ${img} ]] && echo "Could not find ${img} disk file" && exit 1
    cmd="qemu-system-x86_64 \
        -kernel /boot/vmlinuz-`uname -r` \
        -drive file=${img},index=1,media=disk,format=raw \
        -append \"root=/dev/sda\" \
        -enable-kvm \
        -net nic -net user,smb=/mnt/qemu_shared \
        -m $mem
        "
    echo $cmd
    sudo $cmd
}

[[ -n $_create ]] && create_qcow2_image $DISK_IMG $DISK_SZ
[[ -n $_install ]] && install_os_headless "ubuntu20.04" $OS_FILE $DISK_IMG $OS_MEM
[[ -n $_run ]] && run_os $DISK_IMG $OS_MEM
#[[ -n $_run ]] && run_os_host_kernel $DISK_IMG $OS_MEM
