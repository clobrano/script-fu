#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vi: set ft=python :
"""
Reset USB connected device
"""
import os
import sys
from subprocess import Popen, PIPE
import fcntl
import argparse

USBDEVFS_RESET = 21780

if __name__ == "__main__":
    PARSER = argparse.ArgumentParser(usage=__doc__)
    PARSER.add_argument("target")
    OPTS = PARSER.parse_args()

    print("looking for device '%s'" % OPTS.target)

    try:
        LSUSB_OUT = (
            Popen(
                "lsusb | grep -i '%s'" % OPTS.target,
                shell=True,
                bufsize=64,
                stdin=PIPE,
                stdout=PIPE,
                close_fds=True,
            )
            .stdout.read()
            .strip()
            .decode()
        )
        if not LSUSB_OUT:
            print("cannot find any device")
            sys.exit(0)
        print("found: %s" % LSUSB_OUT)
        LSUSB_OUT = LSUSB_OUT.split()
        try:
            BUS = str(LSUSB_OUT[1])
            DEVICE = LSUSB_OUT[3][:-1]
        except IndexError as err:
            print("cannot get BUS and/or Device numbers from %s" % LSUSB_OUT)
            sys.exit(1)

        PATH = r"/dev/bus/usb/%s/%s" % (BUS, DEVICE)

        print("about to reset device at path %s" % PATH)
        input("press ENTER to continue")

        DEVFILE = open(PATH, "w", os.O_WRONLY)
        fcntl.ioctl(DEVFILE, USBDEVFS_RESET, 0)
    except Exception as msg:
        print("failed to reset device %s: %s" % (DEVICE, msg))
