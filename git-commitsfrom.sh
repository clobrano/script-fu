#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
# Helper script to show the number of commits between current HEAD and a given commit by description
set -e

git log --oneline --grep="$@"
candidates=`git log --oneline --grep="$@" | wc -l`
if [[ $candidates -lt 1 ]]; then
    echo "[!] no commits found with filter: $@"
    exit 1
fi
if [[ $candidates -gt 1 ]]; then
    echo "[!] got too many candidates"
    exit 1
fi

echo "[+] continue with the above commit?"
read

HEAD=`git log --oneline -1 | awk '{print $1}'`
selection=`git log --oneline --grep="$@" | awk '{print $1}'`

commits=`git rev-list ${HEAD_HASH}...$selection | wc -l`
let rebase=$commits+1
echo "[+] commit $selection is $commits commit(s) behind HEAD ($HEAD)"
echo "[+] would you like the git rebase command in your clipboard?"
read
echo  "git rebase -i HEAD~$rebase" | xclip -sel clipboard
