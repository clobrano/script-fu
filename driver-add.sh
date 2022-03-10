#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to assign product VID/PID to a given driver
## usage: driver_add_vid_pid.sh [options]
##     -d <driver>
##     -v <vid>
##     -p <pid>
##
## dependencies: tee

which tee > /dev/null
[ $? == 1 ] && echo "Please install tee first" && exit 1

[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

while getopts 'hd:v:p:' OPT; do
    case $OPT in
        h)
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
        d)
            _driver=$OPTARG
            ;;
        v)
            _vid=$OPTARG
            ;;
        p)
            _pid=$OPTARG
            ;;
        \?)
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done

if [ $_driver == 'option' ]; then
    echo $_vid $_pid | sudo tee /sys/bus/usb-serial/drivers/option1/new_id
    exit 0
fi

if [ $_driver == 'qmi_wwan' ]; then
    set -x
    echo $_vid $_pid | sudo tee /sys/bus/usb/drivers/qmi_wwan/new_id
    exit 0
fi

if [ $_driver == 'gobiserial' ]; then
    set -x
    echo $_vid $_pid | sudo tee "/sys/bus/usb-serial/drivers/GobiSerial driver/new_id"
    exit 0
fi

echo "Driver '$_driver' is not supported"
