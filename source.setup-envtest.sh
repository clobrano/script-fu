#!/usr/bin/env bash
# find kubectl subdirectory only in go projects

if [[ -f ./go.mod ]] then
  kubectl_location=$(find -type f -name kubectl -exec realpath {} \;)
  # exit error if not found or too many found
  if [[ -z "${kubectl_location}" ]]; then
    echo "[!] kubectl not found" >&2
  elif [[ $(echo "${kubectl_location}" | wc -l) -gt 1 ]]; then
    echo "[!] multiple kubectl found" >&2
    echo ${kubectl_location}
  else
    export KUBEBUILDER_ASSETS=$(dirname "${kubectl_location}")
    echo "[+] KUBEBUILDER_ASSETS set to ${KUBEBUILDER_ASSETS}"
  fi
fi
