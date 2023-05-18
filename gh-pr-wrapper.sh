#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## This script is a wrapper around GitHub CLI (gh) "pr" subcommand.

set -eu

gh pr list $@
echo "[+] Select a PR to checkout, or CTRL-C to exit"
read SEL
gh pr checkout $SEL
gh pr view

