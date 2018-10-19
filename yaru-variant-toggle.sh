#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to toggle between dark and light Yaru variants
## usage: yaru-variant-toggle.sh

# GENERATED_CODE: start

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'h' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# GENERATED_CODE: end

settings=~/.config/gtk-3.0/settings.ini

if  [ ! -f $settings ]; then
    cat << EOF > $settings
[Settings]
gtk-application-prefer-dark-theme=1
EOF
else
    is_dark=$(grep "gtk-application-prefer-dark-theme=1" $settings | wc -l)

    if [ $is_dark == 1 ]; then
        echo switching to light variant
        old=1
        new=0
    else
        echo switching to dark variant
        old=0
        new=1
    fi

    sed -i "s/gtk-application-prefer-dark-theme=$old/gtk-application-prefer-dark-theme=$new/g" $settings
fi
