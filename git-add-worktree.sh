#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

git worktree add -b ${1} ../${1} ${2:-main}
