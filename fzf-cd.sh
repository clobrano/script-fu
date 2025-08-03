#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
# Use fzf to search, select, and change directory

pattern=${1:-""}

# Set the target directory
TARGET_DIR="$HOME"
MAXDEPTH=5

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
# Push the current directory onto the stack
pushd "$TARGET_DIR" > /dev/null || exit 1

# Use fzf to select a directory
SELECTED_DIR=$(find . -maxdepth "$MAXDEPTH" -type d -not -path "*/.git*" | sort | \
    fzf --prompt "Search a workspace > " \
        --layout reverse \
        --height=70% --query="$pattern")

# Check if a directory was selected
if [ -z "$SELECTED_DIR" ]; then
    echo "No directory selected."
    popd || exit 1
    exit 0
fi

# Change directory to the selected directory
cd "$SELECTED_DIR" || {
    popd > /dev/null || exit 1
    exit 1
}
