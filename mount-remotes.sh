#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -eu
pass=${1}
user=${2:-$USER}


remotes=("srv-its-file02/SW_Develop" "srv-its-file02/SW_Released" "srv-krs-file01/SW_Develop")
for r in ${remotes[@]}; do
    if [[ ! -d /mnt/${r} ]]; then
        echo [!] could not mount ${r}, missing mountpoint under /mnt
        continue
    fi
    if mount | grep ${r} 2>&1>/dev/null; then
        echo [+] ${r} already mounted
        continue
    fi
    sudo mount -t cifs -o username=${user},password="${pass}",workgroup=TMT //${r} /mnt/${r}
done
