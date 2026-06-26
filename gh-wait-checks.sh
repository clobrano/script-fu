#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

title=$(gh pr view --json title | jq ".title")
number=$(gh pr view --json number | jq ".number")
gh pr checks --watch && \
    notify-send "$title PR$number" "Checks PASSED" || \
    notify-send "$title PR$number" "Checks FAILED"
