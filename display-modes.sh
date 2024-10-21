#!/usr/bin/env bash
# -*- coding: UTF-8 -*-


if [[ ! -f ~/.philips-display.yaml ]]; then
    cat << EOF > ~/.philips-display.yaml
options:
  gamma-values:
    180: ddcutil setvcp 0x72 0x50
    200: ddcutil setvcp 0x72 0x64
    220: ddcutil setvcp 0x72 0x78
    240: ddcutil setvcp 0x72 0x8c
    260: ddcutil setvcp 0x72 0xa0
  input-source:
    display-port: ddcutil setvcp 0x60 0x0f
    usbc: ddcutil setvcp 0x60 0x10
    hdmi: ddcutil setvcp 0x60 0x11
  display-modes:
    deactivated: ddcutil setvcp 0xdc 0x00
    low-blue-mode: ddcutil setvcp 0xdc 0x0b
EOF
fi

option=$(yq eval ".options | keys" ~/.philips-display.yaml | awk '{print $2}' | fzf)
value=$(yq eval ".options.${option} | keys" ~/.philips-display.yaml | awk '{print $2}' | fzf)
cmd=$(yq eval ".options.${option}.${value}" ~/.philips-display.yaml)
echo "$cmd"
eval ${cmd}

