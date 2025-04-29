#!/usr/bin/env bash
set -e
# -*- coding: UTF-8 -*-
## Git config --local user.name and user.email
## options
## -p, --personal  User personal email
## -w, --work      User work email

# CLInt GENERATED_CODE: start
# info: https://github.com/clobrano/CLInt.git

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' "$0" && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--personal") set -- "$@" "-p";;
"--work") set -- "$@" "-w";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo "[!] Unexpected flag in command line $*"
}

# Parsing flags and arguments
while getopts 'hpw' OPT; do
    case "$OPT" in
        h) sed -ne 's/^## \(.*\)/\1/p' "$0"
           exit 1 ;;
        p) _personal=1 ;;
        w) _work=1 ;;
        \?) print_illegal "$@" >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' "$0"
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end

if [ -n "$_personal" ]; then 
    EMAIL="$GIT_PERS_EMAIL"
fi

if [ -n "$_work" ]; then
    EMAIL="$GIT_WORK_EMAIL"
fi

set -u
git config --local user.name "Carlo Lobrano"
git config --local user.email "$EMAIL"

