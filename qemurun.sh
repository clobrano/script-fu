#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to run QEMU images from configuration file
## options:
##     -c, --config <path>  Path to the configuration file
##     -n, --new            Generate a new cfg file (to be used with --config to give file path)
##     -e, --edit           Edit the configuration file before running qemu
##     -k, --kill           Kill the running VM


# CLInt GENERATED_CODE: start

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--config") set -- "$@" "-c";;
"--new") set -- "$@" "-n";;
"--edit") set -- "$@" "-e";;
"--kill") set -- "$@" "-k";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hnekc:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        n) _new=1 ;;
        e) _edit=1 ;;
        k) _kill=1 ;;
        c) _config=$OPTARG ;;
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

CONF=$_config
if [[ -n $_edit ]]; then
    editor $CONF
    echo "Run qemu with current $CONF? [ENTER/CTRL-C]"
    read
fi

HEADLESS=`grep "HEADLESS=" "$CONF" 2>/dev/null | cut -d"=" -f2`
HEADLESS=${HEADLESS:-"false"}
ARCH=`grep "ARCH=" "$CONF" 2>/dev/null | cut -d"=" -f2`
ARCH=${ARCH:-"x86_64"}
BZIMAGE=`grep "BZIMAGE=" "$CONF" 2>/dev/null | cut -d"=" -f2`
IMG=`grep "IMG=" "$CONF" 2>/dev/null | cut -d"=" -f2`
ROOT=`grep "ROOT=" "$CONF" 2>/dev/null | cut -d"=" -f2`
ROOT=${ROOT:-"/dev/sda5"}
RAM=`grep "RAM=" "$CONF" 2>/dev/null | cut -d"=" -f2`
RAM=${RAM:-"2G"}
SPICE=`grep "SPICE=" "$CONF" 2>/dev/null | cut -d"=" -f2`
SPICE=${SPICE:-"false"}
USBPASSTHROUGH=`grep "USBPASSTHROUGH=" "$CONF" 2>/dev/null | cut -d"=" -f2`
USBPASSTHROUGH=${USBPASSTHROUGH:-""}

if [[ -n $_new ]]; then
    echo "Creating new configuration file $_config"
    if [[ -f $_config ]]; then
        echo "[!] $_config file exists already!"
        exit 1
    fi
    echo "ARCH=$ARCH" >> $_config
    echo "RAM=$RAM" >> $_config
    echo "IMG=" >> $_config
    echo "ROOT=$ROOT" >> $_config
    echo "HEADLESS=$HEADLESS" >> $_config
    echo "SSHPORTNO=$SSHPORTNO" >> $_config
    exit 0
fi


if [[ -n $BZIMAGE ]] && [[ $HEADLESS == "false" ]]; then
    echo "[!] bzImage won't be used because HEADLESS is FALSE (set HEADLESS to TRUE to use bzImage)!"
    echo "[+] Press ENTER to continue (or CTRL-C to interrupt)"
    read
fi


OPTS=()

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
OPTS+=(-drive file=$IMG,if=virtio)

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
    spicy -h 127.0.0.1 -p 5900
fi

if [[ -f /tmp/qemu.pid ]]; then
    kill $(cat /tmp/qemu.pid)
fi
