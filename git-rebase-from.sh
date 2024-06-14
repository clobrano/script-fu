#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to start an interactive rebase from a specific commit using FZF to select it.
set -e

# git log oneline cmd
cmd="git log --oneline --no-merges"

# use FZF to select a commit
selection=`$cmd | fzf -0 --preview 'git show --color=always --format=oneline {1}' \
    --header $'Press ENTER to select the commit' \
    --layout=reverse --info=inline --no-multi --height=50% --border \
    --prompt 'Search >' \
    | awk '{print $1}'`

# Do not continue if FZF was aborted
[[ -z $selection ]] && exit 0

# compute rebase span
commits=`git rev-list ${HEAD_HASH}...$selection | wc -l`
let rebase=$commits+1

# start interactive rebase
git rebase -i HEAD~$rebase
