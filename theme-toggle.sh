#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
current=$(gsettings get org.gnome.desktop.interface gtk-theme)
set -x
gsettings set org.gnome.desktop.interface gtk-theme Highcontrast
gsettings set org.gnome.desktop.interface gtk-theme $current
