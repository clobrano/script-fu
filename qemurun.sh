#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to run QEMU images from configuration file
## options:
##     -c, --config <name>    Configuration name (e.g. ubuntu-22.04)
##     -n, --new              Generate a new cfg file (to be used with --config to give file path)
##     -s, --disk_size <size> Size of the disk IMG to be created (to be used with --new)
##     -e, --edit             Edit the configuration file before running qemu (to be used with --config to give file path)
##     -i, --iso <path>       Path to the ISO image to run (for installing the VM)
##     -k, --kill             Kill the running VM


# CLInt GENERATED_CODE: start
# info: https://github.com/clobrano/CLInt.git

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--config") set -- "$@" "-c";;
"--new") set -- "$@" "-n";;
"--disk_size") set -- "$@" "-s";;
"--edit") set -- "$@" "-e";;
"--iso") set -- "$@" "-i";;
"--kill") set -- "$@" "-k";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hnekc:s:i:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        n) _new=1 ;;
        e) _edit=1 ;;
        k) _kill=1 ;;
        c) _config=$OPTARG ;;
        s) _disk_size=$OPTARG ;;
        i) _iso=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end

if [[ -n $_kill ]]; then
    kill $(cat /tmp/qemu.pid)
    exit 0
fi

CONF_NAME=$_config
CONF=${CONF_NAME}/${CONF_NAME}.cfg

if [[ -n $_edit ]]; then
    edit $CONF
    echo "Run qemu with current $CONF? [ENTER/CTRL-C]"
    read
fi

ARCH=`grep "ARCH=" "$CONF" 2>/dev/null | cut -d"=" -f2`
ARCH=${ARCH:-"x86_64"}
BZIMAGE=`grep "BZIMAGE=" "$CONF" 2>/dev/null | cut -d"=" -f2`
DISK=`grep "DISK=" "$CONF" 2>/dev/null | cut -d"=" -f2`
DISK=${DISK:-"30G"}
HEADLESS=`grep "HEADLESS=" "$CONF" 2>/dev/null | cut -d"=" -f2`
HEADLESS=${HEADLESS:-"false"}
IMG=`grep "IMG=" "$CONF" 2>/dev/null | cut -d"=" -f2`
IMG=${IMG:-"$CONF_NAME".img}
RAM=`grep "RAM=" "$CONF" 2>/dev/null | cut -d"=" -f2`
RAM=${RAM:-"4G"}
ROOT=`grep "ROOT=" "$CONF" 2>/dev/null | cut -d"=" -f2`
ROOT=${ROOT:-"/dev/sda3"}
SPICE=`grep "SPICE=" "$CONF" 2>/dev/null | cut -d"=" -f2`
SPICE=${SPICE:-"true"}
SPICY=`grep "SPICY=" "$CONF" 2>/dev/null | cut -d"=" -f2`
SPICY=${SPICY:-"false"}
SSHPORTNO=`grep "SSHPORTNO=" "$CONF" 2>/dev/null | cut -d"=" -f2`
SSHPORTNO=${SSHPORTNO:-"2222"}
USBPASSTHROUGH=`grep "USBPASSTHROUGH=" "$CONF" 2>/dev/null | cut -d"=" -f2`
USBPASSTHROUGH=${USBPASSTHROUGH:-""}


if [[ -n $_new ]]; then
    echo "[+] Creating new configuration file $CONF"
    [[ -f "$CONF" ]] && echo "[!] $CONF file exists already!" && exit 1
    [[ ! -d "$CONF_NAME" ]] && mkdir "$CONF_NAME"
    if [[ -n $_disk_size ]]; then
        DISK=$_disk_size
        qemu-img create -f qcow2 ${CONF_NAME}/$IMG $_disk_size
    fi

    echo "ARCH=$ARCH" > $CONF
    echo "BZIMAGE=$BZIMAGE" >> $CONF
    echo "DISK=$DISK" >> $CONF
    echo "HEADLESS=$HEADLESS" >> $CONF
    echo "IMG=$IMG" >> $CONF
    echo "RAM=$RAM" >> $CONF
    echo "ROOT=$ROOT" >> $CONF
    echo "SPICE=$SPICE" >> $CONF
    echo "SSHPORTNO=$SSHPORTNO" >> $CONF
    if [[ -n $USBPASSTHROUGH ]]; then
        echo "USBPASSTHROUGH=$USBPASSTHROUGH" >> $CONF
    fi
    exit 0
fi


if [[ -n $BZIMAGE ]] && [[ $HEADLESS == "false" ]]; then
    echo "[!] bzImage won't be used because HEADLESS is FALSE (set HEADLESS to TRUE to use bzImage)!"
    echo "[+] Press ENTER to continue (or CTRL-C to interrupt)"
    read
fi


OPTS=()

if [[ -n $_iso ]]; then
OPTS+=(-cdrom ${_iso})
fi

# PIDFILE to be able to shutdown the VM easily
OPTS+=(-pidfile /tmp/qemu.pid)

# Enable KVM
OPTS+=(-enable-kvm)

# Set RAM
OPTS+=( -m $RAM)

# Set number of Cores
OPTS+=( -smp 4)

# Using Host cpu flags (?)
OPTS+=( -cpu host)

if [[ "$HEADLESS" = "true" ]]; then
    # Kernel image to load and configurations
    OPTS+=(-kernel $BZIMAGE)
    # No need to use much RAM in HEADLESS mode
    RAM=1G
    OPTS+=( -append "root=$ROOT console=ttyS0 rw")
    OPTS+=(-serial mon:stdio)
    OPTS+=(-display none)
fi

# Set the IMG to use
OPTS+=(-drive file="$CONF_NAME"/"$IMG",if=virtio)

echo $SPICE
if [[ $SPICE = "true" ]]; then
    # Spice configuration
    OPTS+=(-vga qxl)
    OPTS+=(-spice port=5900,addr=127.0.0.1,disable-ticketing=on
            -device virtio-serial-pci
            -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0
            -chardev spicevmc,id=spicechannel0,name=vdagent)

    # enable usb passthroug
    OPTS+=(-device qemu-xhci,id=spicepass
            -chardev spicevmc,id=usbredirchardev1,name=usbredir
            -device usb-redir,chardev=usbredirchardev1,id=usbredirdev1
            -chardev spicevmc,id=usbredirchardev2,name=usbredir
            -device usb-redir,chardev=usbredirchardev2,id=usbredirdev2
            -chardev spicevmc,id=usbredirchardev3,name=usbredir
            -device usb-redir,chardev=usbredirchardev3,id=usbredirdev3)

    # filesystem sharing
    PUBLIC=$(xdg-user-dir PUBLICSHARE)  
    PUBLIC_TAG="public-${USER,,}"
    OPTS+=(-virtfs local,path="${PUBLIC}",mount_tag="${PUBLIC_TAG}",security_model=mapped-xattr)
else
    # Try to build USB passthrough configuration (not actually working with spice)
    for id in `echo $USBPASSTHROUGH`; do
        VID=`echo $id | cut -d":" -f1`
        PID=`echo $id | cut -d":" -f2`
        OPTS+=(-usb -device usb-host,vendorid="$VID",productid="$PID")
    done
fi

ARGS="${OPTS[*]}"

set -u
echo "[+] Running the following qemu line:"
echo ""
echo "qemu-system-$ARCH ${ARGS}"
echo " "
echo "[+] Press ENTER to continue, CTRL-C to stop"
read

qemu-system-$ARCH ${ARGS[@]} &
if [[ $SPICE = "true" ]]; then
if [[ $SPICY = "true" ]]; then
    spicy -h 127.0.0.1 -p 5900 &
    if [[ -f /tmp/qemu.pid ]]; then
        kill $(cat /tmp/qemu.pid)
    fi
fi


