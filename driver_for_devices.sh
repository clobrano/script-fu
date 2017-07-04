#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to find the driver associated to the given linux device
## usage: get_driver_for_device.sh [options]
## options:
##    -d <device>     The path to the device. (TODO: let prepend /dev unnecessary)
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1
while getopts 'hd:' OPT; do
    case $OPT in
        h)
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
        d)
            _device=$OPTARG
            ;;
        \?)
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done

[ -z ${_device} ] && echo "device name is needed" && exit 1

dev_spec=$(ls -l $_device)
echo $dev_spec

# Get device type
[[ ${dev_spec} == b* ]] && dev_type="block"
[[ ${dev_spec} == c* ]] && dev_type="char"
[ -z ${dev_type} ] && echo "${_device} is not block nor character device." && exit 1

# Get major and minor number
# transform ls -s string in array
read -ra DEV_SPEC <<< "$dev_spec"

# Parameter expansion to get rid of the comma attached to the major number
major=${DEV_SPEC[4]%?}
minor=${DEV_SPEC[5]}

rv=`readlink -f /sys/dev/"$dev_type"/"$major"\\:"$minor"/device/driver/`
if [ -z $rv ]; then
    echo "No driver found"
else
    echo $rv
fi
