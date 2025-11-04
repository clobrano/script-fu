#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

# Ensure Alacritty and bash are called with their full paths for robustness
ALACRITTY_PATH=$(command -v alacritty)
BASH_PATH=$(command -v bash)

# Fallback if command -v doesn't find them (less common for these, but good practice)
[[ -z "$ALACRITTY_PATH" ]] && ALACRITTY_PATH="/usr/bin/alacritty"
[[ -z "$BASH_PATH" ]] && BASH_PATH="/usr/bin/bash"

# The key change is adding '; exec "$BASH_PATH"' to the END of the inner bash -c command
"$ALACRITTY_PATH" -e "$BASH_PATH" -c "/home/clobrano/workspace/script-fu/BookMarkIt; exec \"$BASH_PATH\""
