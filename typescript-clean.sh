#!/usr/bin/bash
input=$1
output=${2:-$input.clean}
set -u
if [[ -f $output ]]; then
    echo "[!] file '$output' already exists! Replace it? [Enter/Ctrl-C]"
    read
fi
cat $input | perl -pe 's/([^\[\]]|\[.*?[a-zA-Z]|\].*?)//g' | col -b > $output
