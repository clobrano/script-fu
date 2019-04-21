#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
declare -A hex2bin=(
    ["0"]="0000"
    ["1"]="0001"
    ["2"]="0010"
    ["3"]="0011"
    ["4"]="0100"
    ["5"]="0101"
    ["6"]="0110"
    ["7"]="0111"
    ["8"]="1000"
    ["9"]="1001"
    ["a"]="1010"
    ["b"]="1011"
    ["c"]="1100"
    ["d"]="1101"
    ["e"]="1110"
    ["f"]="1111"
    ["A"]="1010"
    ["B"]="1011"
    ["C"]="1100"
    ["D"]="1101"
    ["E"]="1110"
    ["F"]="1111"
)

input=$1
i=0
for c in `echo $input | sed -e 's/\(.\)/\1\n/g'`; do
    echo -n ${hex2bin[$c]}
    if [[ $i == 1 ]]; then
        echo -n .
        let i=0
    else
        echo -n -
        let i=$i+1
    fi
done
echo

