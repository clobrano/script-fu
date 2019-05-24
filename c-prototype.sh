#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to create a default main.c and Makefile for prototyping
## usage:
##      c-prototype.sh --name <string>
##
## options:
##      -n, --name <string> Name of the project, that will be used as directory name
# GENERATED_CODE: start

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--name") set -- "$@" "-n";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hn:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        n) _name=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# GENERATED_CODE: end

set -eu

mkdir -p ${_name}

cat <<EOF >${_name}/main.c
#include <stdio.h>

int main(int argc, char **argv)
{
    return 0;
}
EOF

cat <<EOF>${_name}/Makefile
CFLAGS  := -g -Wall
LDFLAGS :=

all:
	\$(CC) \$(CFLAGS) main.c -o ${_name} \$(LDFLAGS)
EOF
