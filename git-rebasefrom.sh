#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to show the number of commits between current HEAD and a commit matching the input query.
## Moreover, the script provides the command to git-rebase such commit.
## e.g.
## 
## $ git-commitsfrom.sh "Support Proce"
##   4bb53dc Support Processing and Succeeded conditions
##   [+] continue with the above commit?
##
##   [+] commit 4bb53dc is 3 commit(s) behind HEAD (da2437f)
##   [+] edit the commit with:
##   [+]     git rebase -i HEAD~4
##   [+] would you like to have the above command in your clipboard?

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
echo "[+] about to edit the commit with:"
echo "[+]     git rebase -i HEAD~$rebase"
echo "[+] continue?"
git rebase -i HEAD~$rebase
