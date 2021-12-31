#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -u

# is running X11?
compositor=`loginctl show-session $(awk '/tty/ {print $1}' <(loginctl)) -p Type | awk -F= '{print $2}'`

if [[ $compositor != "x11" ]]; then
    echo "It seems you are running Wayland, which does not support this script"
    exit 0
fi
# get trackpoint ID
dev_id=$(xinput list | grep -i "trackpoint" | grep -o "id=[0-9]*" | cut -d'=' -f2)
# get property ID
prop_id=$(xinput list-props $dev_id | grep -o "libinput Accel Speed ([0-9]*)" | cut -d' ' -f4)

# set property (prop_id has format "(<number>)" so it needs to be sliced)
set -x
xinput set-prop $dev_id ${prop_id:1:-1} -0.5
