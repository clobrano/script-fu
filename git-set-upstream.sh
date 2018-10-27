#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## helper script to 'git push --set-upstream' current branch
current=$(git rev-parse --abbrev-ref HEAD)
echo git push --set-upstream origin ${current}? CTLR-C to interrupt
read
git push --set-upstream origin ${current}