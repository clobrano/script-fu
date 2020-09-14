#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -x
sudo apt install -y flatpak
sudo apt install -y gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
set +x
