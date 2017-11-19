#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## options:
##    -a, --all
##    -g, --github    ssh-add github keys
##    -l, --launchpad    ssh-add launchpad keys
# GENERATED_CODE: start

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--all") set -- "$@" "-a";;
"--github") set -- "$@" "-g";;
"--launchpad") set -- "$@" "-l";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hagl' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        a) _all=1 ;;
        g) _github=1 ;;
        l) _launchpad=1 ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# GENERATED_CODE: end

[[ $_all || $_github ]] && {
    ssh-add  ~/.ssh/github/id_rsa
}

[[ $_all || $_launchpad ]] && {
    ssh-add  ~/.ssh/launchpad/id_rsa_lp
}
