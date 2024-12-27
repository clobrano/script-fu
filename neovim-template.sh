#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
# Neovim script to create templates. I want a bash script to be able to use it from CLI and inside Neovim with some mapping.
# The script shall be able to pick the right template for the right document.
set -ue

kind=$1
shift
filename=$@

resource_template()
{
    printf "\n
# $filename
created:$(date +%F)



<!-- references -->
\n"
}

case $kind in
    day)
        day_template;;
    reference)
        reference_template;;
    resource)
        resource_template;;
    *)
        echo "[!] unsupported kind:$kind"
        exit 1
esac

