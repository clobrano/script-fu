#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to run QEMU images from configuration file
## options:
##     -c, --config <path> Path to the configuration file
##     -e, --edit Edit the configuration file before running qemu

# CLInt GENERATED_CODE: start

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--config") set -- "$@" "-c";;
"--edit") set -- "$@" "-e";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hec:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        e) _edit=1 ;;
        c) _config=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end

CONF=$_config
if [[ -n $_edit ]]; then
    editor $CONF
    echo "Run qemu with current $CONF? [ENTER/CTRL-C]"
    read
fi

ARCH=`grep "ARCH=" "$CONF" | cut -d"=" -f2`
ARCH=${ARCH:-"x86_64"}

BZIMAGE=`grep "BZIMAGE=" "$CONF" | cut -d"=" -f2`
IMG=`grep "IMG=" "$CONF" | cut -d"=" -f2`

ROOT=`grep "ROOT=" "$CONF" | cut -d"=" -f2`
ROOT=${ROOT:-"/dev/sda5"}

RAM=`grep "RAM=" "$CONF" | cut -d"=" -f2`
RAM=${RAM:-"2G"}

SSHPORTNO=`grep "SSHPORTNO=" "$CONF" | cut -d"=" -f2`
SSHPORTNO=${SSHPORTNO:-2222}

HEADLESS=`grep "HEADLESS=" "$CONF" | cut -d"=" -f2`
HEADLESS=${HEADLESS:-"false"}

USBPASSTHROUGH=`grep "USBPASSTHROUGH=" "$CONF" | cut -d"=" -f2`
USBPASSTHROUGH=${USBPASSTHROUGH:-""}

PIDFILE=/tmp/qemu.pid

if [[ -n $BZIMAGE ]] && [[ $HEADLESS == "false" ]]; then
    echo "[!] bzImage won't be used because HEADLESS is FALSE (set HEADLESS to TRUE to use bzImage)!"
    echo "[+] Press ENTER to continue (or CTRL-C to interrupt)"
    read
fi

# Build usb passthrough configuration
usbpassthroug=""
for id in `echo $USBPASSTHROUGH`; do
    VID=`echo $id | cut -d":" -f1`
    PID=`echo $id | cut -d":" -f2`
    usbpassthroug+="-usb -device usb-host,vendorid=$VID,productid=$PID "
done

if [[ "$HEADLESS" = "true" ]]; then
    set -xu
    sudo qemu-system-$ARCH \
        -pidfile $PIDFILE \
        -kernel $BZIMAGE \
        -append "root=$ROOT console=ttyS0" -serial mon:stdio -display none \
        -hda $IMG \
        -m $RAM \
        -enable-kvm \
        -net nic -net user,hostfwd=tcp::$SSHPORTNO-:22 \
        $usbpassthroug   
else
    set -xu
    sudo qemu-system-$ARCH \
        -pidfile $PIDFILE \
        -hda $IMG \
        -m ${RAM} \
        -enable-kvm \
        -M q35 \
        -smp 2 \
        -cpu host \
        -net nic -net user,hostfwd=tcp::$SSHPORTNO-:22 \
        $usbpassthroug
fi
