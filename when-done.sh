#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
query=$1
pid=$(pgrep "${query}")

occurrences=$(echo "${pid}" | wc -w)
if [[ ${occurrences} -eq 0 ]]; then
    echo "[!] No matching processes for query: \"${query}\"."
    exit 1
fi
if [[ ${occurrences} -gt 1 ]]; then
    echo "[!] found too many (${occurrences}) matching processes. Use a more specific query"
    exit 1
fi

# read process' command line
cmd=$(cat /proc/${pid}/cmdline | sed -e "s/\x00/ /g"; echo)
echo "got pid: \"${pid}\" for query: \"${query}\", with cmdline: \"${cmd}\""
echo "confirm?"
read

echo "Let's wait"
tail --pid=${pid} --follow /dev/null
