#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -u

# get trackpoint ID
dev_id=$(xinput list | grep -i "trackpoint" | grep -o "id=[0-9]*" | cut -d'=' -f2)
# get property ID
prop_id=$(xinput list-props $dev_id | grep -o "libinput Accel Speed ([0-9]*)" | cut -d' ' -f4)

# set property (prop_id has format "(<number>)" so it needs to be sliced)
set -x
xinput set-prop $dev_id ${prop_id:1:-1} -0.6

