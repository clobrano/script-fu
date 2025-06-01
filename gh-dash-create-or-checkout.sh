#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script for gh-dash keybindings
## Given the RepoName it clone the repo if it does not exist
## Given the PrNumber, checks out the PR
set -ue

# The full name of the repo (e.g. dlvhdr/gh-dash)
REPO_NAME=$1
# The PR number
PR_NUMBER=$2

CODEREVIEW_DIR="/home/clobrano/workspace/codeReviews/"
REPO_DIR="$CODEREVIEW_DIR/$REPO_NAME"

if [ ! -d "$REPO_DIR" ]; then
    pushd "$CODEREVIEW_DIR" || exit 1
    gh repo clone "$REPO_NAME" "$REPO_NAME"
    #git clone "https://github.com/$REPO_NAME" "$REPO_NAME"
    cd "$REPO_NAME"
    git-config.sh --personal
    popd || exit 1
fi

#pushd "$REPO_DIR" || exit 1
#gh pr checkout "$PR_NUMBER"
#popd || exit
