#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
# Ver often working with ModemManager main branch requires to update the other projects too. Let's script it

set -e

deps=(libqrtr-glib libqmi libmbim)
for dep in ${deps[@]}; do
    pushd $dep

    echo [+] Updating $dep
    git checkout main
    git pull origin main

    if [[ ! -d build ]]; then
        meson build --prefix=/usr
    fi
    pushd build
    echo [+] building $dep
    ninja
    ninja install
    popd
    popd
done
