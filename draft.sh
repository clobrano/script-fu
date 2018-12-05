#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Simple and lazy script to write NEOVIM draft in $HOME/.drafts folder
set -eu
NAME=$1

[ ! -d ${HOME}/.drafts ] && mkdir ${HOME}/.drafts
nvim -c "Writer" ${HOME}/.drafts/$NAME.md

