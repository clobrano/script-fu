#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## This script adds a new Git worktree, creating a new branch and linking it to a specified upstream branch.

git worktree add -b ${1} ../${1} ${2:-main}
