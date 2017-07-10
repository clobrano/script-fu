#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
# GtkInspector depends on libgkt-3-dev

set -u
app=$1
gsettings set org.gtk.Settings.Debug enable-inspector-keybinding true
GTK_DEBUG=interactive $app
