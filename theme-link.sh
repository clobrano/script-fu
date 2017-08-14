#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to link the current folder in $HOME/.themes and simplify themes bug fixing
## options
##      -n <link_name>   Link name

# Parsing flags and arguments
while getopts 'hn:' OPT; do
    case $OPT in
        h)
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
        n)
            _link_name=$OPTARG
            ;;
        \?)
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done

CWD=`pwd`
[ -z ${_link_name} ] && echo "using folder name as link's name" && _link_name=$(basename $CWD)

new_alias=$HOME/.themes/${_link_name}

echo linking [$CWD] to [${new_alias}] "(Y/N)"?
read response
case $response in
    n|N)
        exit 0
        ;;
    *)
        echo please write y/Y or n/N
        exit 1
esac

[ -e ${new_alias} ] && echo "${new_alias} already exists" && exit 1
[ ! -d $HOME/.themes ] && echo "creating $HOME/.themes folder" && mkdir $HOME/.themes
set -x
ln -s ${CWD} ${new_alias}

