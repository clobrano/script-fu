#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
query=$1
pids=( $(pgrep "${query}") )

occurrences=${#pids[@]}
if [[ ${occurrences} -eq 0 ]]; then
    echo "[!] No matching processes for query: \"${query}\"."
    exit 1
fi

echo "[+] found ${occurrences} the following process(es). Confirm one:"
for i in ${!pids[@]}; do
    pid=${pids[$i]}
    cmd=$(cat /proc/${pid}/cmdline | sed -e "s/\x00/ /g"; echo)
    echo "- type $i for pid: \"${pid}\", with cmdline: \"${cmd}\""
done

read sel
pid=${pids[$sel]}
cmd=$(cat /proc/${pid}/cmdline | sed -e "s/\x00/ /g"; echo)

echo -e "Let's wait for ${pid}: \e[4m${cmd}\e[0m to end"
tail --pid=${pid} --follow /dev/null
