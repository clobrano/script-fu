#!/usr/bin/env python
# -*- coding: utf-8 -*-
# vi: set ft=python :
import os
import sys
from subprocess import Popen, PIPE
import fcntl
USBDEVFS_RESET = 21780

if __name__ == '__main__':
    driver = sys.argv[-1]
    print("resetting driver: %s" % driver)

    try:
        lsusb_out = Popen('lsusb | grep -i %s' % driver, shell=True, bufsize=64, stdin=PIPE, stdout=PIPE, close_fds=True).stdout.read().strip().split()
        bus = lsusb_out[1]
        device = lsusb_out[3][:-1]
        print('bus: %s, device %s' % (bus, device))
        f = open('/dev/bus/usb/%s/%s' % (bus, device), 'w', os.O_WRONLY)
        fcntl.ioctl(f, USBDEVFS_RESET, 0)
    except Exception, msg:
        print("failed to reset device %s: %s" % (driver, msg))

