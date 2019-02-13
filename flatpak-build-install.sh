#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
json=`find . -name *.json`

echo install $json ?
read
flatpak-builder builddir $json --force-clean --user --install
