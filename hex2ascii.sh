#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## option
## -d, --data <hex> sequence of hex bytes (e.g. 0x44,0x47,0x4e)
## -s, --sep <char> separator character [default: ,]
# GENERATED_CODE: start
# Default values
_sep=,

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--data") set -- "$@" "-d";;
"--sep") set -- "$@" "-s";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hd:s:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        d) _data=$OPTARG ;;
        s) _sep=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# GENERATED_CODE: end

TESTDATA=$(echo "$_data" | tr "$_sep" ' ')
echo parsing:\'$TESTDATA\', with separator:\'$_sep\'
for c in $TESTDATA; do
    echo $c | xxd -r
done
echo ''
