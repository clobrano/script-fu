#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## options:
##    -l, --list         list available private keys
##    -n, --name <name>  add the given key
##    -a, --all          add ALL the keys

# CLInt GENERATED_CODE: start

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--list") set -- "$@" "-l";;
"--name") set -- "$@" "-n";;
"--all") set -- "$@" "-a";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hlan:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        l) _list=1 ;;
        a) _all=1 ;;
        n) _name=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end
if [[ $_list ]]; then
    ls ~/.ssh | grep -iv -e known_hosts -e pub
    exit 0
fi

if [[ $_name ]]; then
    fullname=$(find ~/.ssh -name "*$_name*" | grep -iv -e pub)
    [[ ! -f "$fullname" ]] && echo "Could not find any file with keyword $_name" && exit 1
    echo adding $fullname
    ssh-add $fullname
    exit 0
fi

if [[ $_all ]]; then
    for file in $(ls ~/.ssh/ | grep -iv -e pub -e known_hosts); do
        echo adding ~/.ssh/$file
        ssh-add ~/.ssh/$file
    done
fi
