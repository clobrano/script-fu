#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## this script helps using AT commands to manage SMS
##
## options
## -d, --device <path>  Path to device [default: /dev/ttyUSB2]
## -l, --list   List received messages in PDU format
## -p, --pdu <mode>     Set the PDU mode (1:PDU, 0:TEXT)
## -s, --smsc           Get SMSC

# GENERATED_CODE: start
# Default values
_device=/dev/ttyUSB2

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--device") set -- "$@" "-d";;
"--list") set -- "$@" "-l";;
"--pdu") set -- "$@" "-p";;
"--smsc") set -- "$@" "-s";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hlsd:p:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        l) _list=1 ;;
        s) _smsc=1 ;;
        d) _device=$OPTARG ;;
        p) _pdu=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# GENERATED_CODE: end

set -xe

if [[ ! -z $_smsc ]]; then
    sudo sendat -port $_device -command "at+CSCA?"
    exit 0
fi
if [[ ! -z $_pdu ]]; then
    sudo sendat -port $_device -command "at+CMGF=$_pdu"
    exit 0
fi
if [[ ! -z $_list ]]; then
    sudo sendat -port $_device -command "at+CMGL=4"
    exit 0
fi
