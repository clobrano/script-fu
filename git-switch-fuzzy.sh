#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Wrapper around git switch that uses FZF to select branches

git switch --quiet $(git branch -l | sed 's/[+!*]//g' | awk '{print $1}' | fzf --height 60% --reverse --preview "git log --oneline --graph --decorate --color=always {}")
