#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
theme=$(gsettings get org.gnome.desktop.interface gtk-theme)
gsettings set org.gnome.desktop.interface gtk-theme "$theme"
