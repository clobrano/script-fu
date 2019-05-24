#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## helper script to 'git push --set-upstream' current branch
## -r, --remote <string>    Name of the remote to push to [default: origin]
# GENERATED_CODE: start
# Default values
_remote=origin

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--remote") set -- "$@" "-r";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hr:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        r) _remote=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# GENERATED_CODE: end

current=$(git rev-parse --abbrev-ref HEAD)
echo "git push --set-upstream $_remote ${current}? (press ENTER to accept)"
read
git push --set-upstream $_remote ${current}
