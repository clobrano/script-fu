#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
configuration=$1
shift
file=$1
shift
extra_args=$@

set -x
uncrustify -c ${configuration} -f ${file} ${extra_args} | diff -u -- "${file}" -
