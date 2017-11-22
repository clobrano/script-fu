#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Configure $HOME/.themes folder to test changes on GTK+ default theme Adwaita
## options:
##     -s, --source <path>    Full path to gtk+ cloned repository
##     -t, --theme  <name>    Full path to destination folder [default: AdwaitaMod]

# GENERATED_CODE: start
# Default values
_theme=AdwaitaMod

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--source") set -- "$@" "-s";;
"--theme") set -- "$@" "-t";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hs:t:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        s) _source=$OPTARG ;;
        t) _theme=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# GENERATED_CODE: end

[[ ! -d $HOME/.themes ]] && {
    echo creating $HOME/.themes folder...
    mkdir -p $HOME/.themes
    echo done.
}

destination=$HOME/.themes/"$_theme"
[[ -d "$destination" ]] && {
    echo destination folder $destination exists already
    exit 1
}

mkdir -p "$destination"

cd "$destination"
cp /usr/share/themes/Adwaita/index.theme .
ln -s "$_source"/gtk/theme/Adwaita "$destination"/gtk-3.0

cd gtk-3.0
echo '@import url("gtk-contained.css");' > gtk.css

echo $_theme created at $destination
