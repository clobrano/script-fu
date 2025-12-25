#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## This script sets up Flatpak on a system by installing necessary packages and adding the Flathub remote repository.
set -x
sudo apt install -y flatpak
sudo apt install -y gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
set +x
