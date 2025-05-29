#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
# Use fzf to search, select, and change directory

# Set the target directory
TARGET_DIR="$HOME/workspace"
MAXDEPTH=3

# Check if fzf is installed
if ! command -v fzf &> /dev/null
then
    echo "fzf is not installed. Please install it."
    exit 1
fi

# Change directory to TARGET_DIR if it exists
if [ ! -d "$TARGET_DIR" ]; then
  echo "Target directory $TARGET_DIR does not exist"
  exit 1
fi

# Keep pushd in place of cd, as we need to come back to the
# original directory if something does not work in the next steps
pushd "$TARGET_DIR" || exit 1

# Use fzf to select a directory
SELECTED_DIR=$(find . -maxdepth "$MAXDEPTH" -type d -not -path "*/.git*" | sort | \
    fzf --prompt "Search a workspace > " \
        --layout reverse \
        --height=70% \
        --no-sort)

# Check if a directory was selected
if [ -z "$SELECTED_DIR" ]; then
    echo "No directory selected."
    popd || exit 1
else
    # Change directory to the selected directory
    echo "Moving to $TARGET_DIR/$SELECTED_DIR"
    cd "$TARGET_DIR/$SELECTED_DIR" || exit 1
fi


