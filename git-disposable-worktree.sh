#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Create a worktree out of the _REPOSITORY IN CWD_ in /tmp, so disposable. Usually to review some code in PR/MR

CWD_BASENAME=$(basename $(pwd))
git worktree add /tmp/${CWD_BASENAME}
