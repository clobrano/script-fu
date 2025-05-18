#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
# Use fzf to search, select, and change directory

# Set the target directory
TARGET_DIR="$HOME/workspace"

# Check if fzf is installed
if ! command -v fzf &> /dev/null
then
    echo "fzf is not installed. Please install it."
    exit 1
fi

# Change directory to workspace if it exists
if [ ! -d "$TARGET_DIR" ]; then
  echo "Target directory $TARGET_DIR "
  exit 1
fi
pushd "$TARGET_DIR" || exit 1

# Use fzf to select a directory
SELECTED_DIR=$(find . -maxdepth 5 -type d -not -path "*/.git*" | sort | \
    fzf --prompt "Search a workspace > " \
        --layout reverse \
        --height=70%)

# Check if a directory was selected
if [ -z "$SELECTED_DIR" ]; then
    echo "No directory selected."
    popd || exit 1
else
    # Change directory to the selected directory
    cd "$TARGET_DIR/$SELECTED_DIR" || exit 1
fi


