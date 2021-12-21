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

HEADLESS=`grep "HEADLESS=" "$CONF" | cut -d"=" -f2`
HEADLESS=${HEADLESS:-"false"}

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

USBPASSTHROUGH=`grep "USBPASSTHROUGH=" "$CONF" | cut -d"=" -f2`
USBPASSTHROUGH=${USBPASSTHROUGH:-""}

PIDFILE=/tmp/qemu.pid

if [[ -n $BZIMAGE ]] && [[ $HEADLESS == "false" ]]; then
    echo "[!] bzImage won't be used because HEADLESS is FALSE (set HEADLESS to TRUE to use bzImage)!"
    echo "[+] Press ENTER to continue (or CTRL-C to interrupt)"
    read
fi


OPTS=""

# PIDFILE to be able to shutdown the VM easily
OPTS+=" -pidfile $PIDFILE"

# Enable KVM
OPTS+=" -enable-kvm"

# Set RAM
OPTS+=" -m $RAM"

# Set number of Cores
OPTS+=" -smp 4"

# Using Host cpu flags (?)
OPTS+=" -cpu host"

if [[ "$HEADLESS" = "true" ]]; then
    # Kernel image to load and configurations
    OPTS+=" -kernel $BZIMAGE"
    OPTS+=" -append root=$ROOT"
    #OPTS+=" -append root=$ROOT console=ttyS0"  WHY this doesn't work?!?
    #OPTS+=" -serial mon:stdio -display none"
fi

# Set the IMG to use
OPTS+=" -hda $IMG"

# Configure VNC and SSH connection (does this really work?)
OPTS+=" -net nic"
OPTS+=" -net user,hostfwd=tcp::$SSHPORTNO-:22"

# Build USB passthrough configuration
for id in `echo $USBPASSTHROUGH`; do
    VID=`echo $id | cut -d":" -f1`
    PID=`echo $id | cut -d":" -f2`
    OPTS+=" -usb -device usb-host,vendorid=$VID,productid=$PID"
done

set -u
echo "[+] Running the following qemu line:"
echo ""
echo "sudo qemu-system-$ARCH $OPTS"
echo " "
echo "[+] Press ENTER to continue, CTRL-C to stop"
read

sudo qemu-system-$ARCH $OPTS
