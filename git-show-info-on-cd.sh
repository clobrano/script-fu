#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

git_show_info_on_cd() {
    DIR=$1
    cd ${DIR}
    if [[ -d .git ]]; then
        local branch=$(git branch --show-current)
        local email=$(git config user.email)
        local user=$(git config user.name)
        echo "[+] In $branch branch as $user <$email>"
    fi
}

alias cd=git_show_info_on_cd
