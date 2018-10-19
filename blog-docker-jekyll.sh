#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

# https://github.com/envygeeks/jekyll-docker
## build and run jekyll on docker container
## options:
##    -b, --build
##    -s, --serve
# GENERATED_CODE: start

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--build") set -- "$@" "-b";;
"--serve") set -- "$@" "-s";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hbs' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        b) _build=1 ;;
        s) _serve=1 ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# GENERATED_CODE: end

if [ ! -z $_build ]; then
    export JEKYLL_VERSION=3.8
    docker run --rm \
      --volume="$PWD:/srv/jekyll" \
      -it jekyll/jekyll:$JEKYLL_VERSION \
      jekyll build
    exit
fi

if [ ! -z $_serve ]; then
    export JEKYLL_VERSION=3.8
    docker run --rm \
      --volume=$PWD:/srv/jekyll \
      -p 35729:35729 -p 4000:4000 \
      -it jekyll/jekyll:$JEKYLL_VERSION \
      jekyll serve
fi
