#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
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
