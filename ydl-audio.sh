#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## options
##     -f, --format <format> Audio format (opus|mp3) [default: opus]
##     -u, --url <url>
# GENERATED_CODE: start
# Default values
_format=opus

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--format") set -- "$@" "-f";;
"--url") set -- "$@" "-u";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hf:u:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        f) _format=$OPTARG ;;
        u) _url=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# GENERATED_CODE: end

set -exu
youtube-dl --add-metadata --continue -f bestaudio --max-downloads 99 --extract-audio --audio-format "$_format" --audio-quality 100K -o "%(title)s.%(ext)s" "$_url"
