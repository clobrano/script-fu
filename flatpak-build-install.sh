#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## This script automates the Flatpak build and installation process by locating the application's manifest (JSON or YAML) and using it to build and install the Flatpak.
json=`find . -name *.json`
yaml=`find . -name *.yaml`

if [[ -f ${json} ]]; then
    filename=$[json]
else if [[ -f ${yaml} ]]; then
    filename=${yaml}
fi
fi
echo install $filename ?
read
set -x
flatpak-builder builddir ${filename} --force-clean --user --install
