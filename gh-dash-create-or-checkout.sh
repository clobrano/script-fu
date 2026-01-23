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

[[ -d "$REPO_DIR" ]] && rm -rf "$REPO_DIR"
mkdir -p "$REPO_DIR"

pushd "$REPO_DIR" || exit 1

git init
git remote add origin "https://github.com/$REPO_NAME.git"
git fetch --depth 1 origin "pull/$PR_NUMBER/head:pr-$PR_NUMBER"
git checkout "pr-$PR_NUMBER"

popd || exit 1
