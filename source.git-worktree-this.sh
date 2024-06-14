#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
DEST=$HOME/workspace/review-repos
if [ ! -d "$DEST" ]; then
    mkdir -p "$DEST"
fi

CUR_DIR_NAME=$(basename $(pwd))
if [ -d "$DEST/$CUR_DIR_NAME" ]; then
    rm -rf "$DEST/$CUR_DIR_NAME" 
fi
git worktree add -f "$DEST/$CUR_DIR_NAME"
echo "Worktree added to $DEST/$CUR_DIR_NAME"
echo "move to worktree [ENTER]"
read
cd "$DEST/$CUR_DIR_NAME"
