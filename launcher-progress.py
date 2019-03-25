#!/usr/bin/env python
# -*- coding: utf-8 -*-
# vi: set ft=python :

from gi.repository import Unity, Gio, GObject, Dbusmenu

loop = GObject.MainLoop()

launcher = Unity.LauncherEntry.get_for_desktop_id ("update-manager.desktop")

i = 0.0
def progressbar():
    global i
    i += 0.1
    if i >= 1.0:
        return False
    print(i)
    launcher.set_property("progress", i)
    launcher.set_property("progress_visible", True)
    return True

GObject.timeout_add_seconds(1, progressbar)

loop.run()
