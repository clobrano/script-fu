#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to keep logging a node on a given Node

node=$1
ns=${2:-openshift-workload-availability}

if [[ -z "$node" ]]; then
    selection=$(oc get nodes | fzf --height=40 --reverse)
    node=$(echo ${selection} | awk '{print $1}')
fi

doexit() {
    exit 0
}

trap doexit SIGINT

while true; do
    podName=$(kubectl get pod -n "$ns" -l app.kubernetes.io/component=agent --field-selector spec.nodeName="$node" -o yaml | yq ".items[0].metadata.name")
    echo ">>>"
    echo "[+] getting new stream of logs from $podName on $node"
    kubectl logs "$podName" -n "$ns" --follow | raffaello -f ~/.raffaello/snr.raf
    sleep 2
done
