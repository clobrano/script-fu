#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
filename="${1}"


#ffmpeg -i "${filename}".mkv -r 24 ../Rendered/"${filename}".gif


ffmpeg -i "${filename}.mkv" \
-vf "fps=16,split[s0][s1];\
[s0]palettegen=max_colors=128:reserve_transparent=0[p];\
[s1][p]paletteuse" \
-y ../Rendered/"${filename}".gif
