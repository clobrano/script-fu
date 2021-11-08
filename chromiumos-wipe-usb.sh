#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

# helper script to wipe out chromiumos from a pendrive

location=$1

echo [!] are you sure to wipe out ${location} ?
read


echo [+] content of ${location}
sudo fdisk -l ${location}

echo [!] about to delete 12 partitions with fdisk. Continue?
read

sudo fdisk ${location} << EOF
d

d

d

d

d

d

d

d

d

d

d

d

w
EOF

echo [+] content of ${location} after deletion:
sudo fdisk -l ${location}


