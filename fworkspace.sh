#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
# Use fzf to search, select, and change directory into ~/workspace

# Set the workspace directory
WORKSPACE_DIR="$HOME/workspace"

# Check if fzf is installed
if ! command -v fzf &> /dev/null
then
    echo "fzf is not installed. Please install it."
    exit 1
fi

# Change directory to workspace if it exists
if [ ! -d "$WORKSPACE_DIR" ]; then
  echo "Workspace directory '$WORKSPACE_DIR' does not exist. Creating it..."
  mkdir -p "$WORKSPACE_DIR"
fi
cd "$WORKSPACE_DIR" || exit 1

# Use fzf to select a directory
SELECTED_DIR=$(find . -maxdepth 5 -type d -not -path "*/.git*" | fzf --prompt "select a workspace> " --layout=reverse)

# Check if a directory was selected
if [ -z "$SELECTED_DIR" ]
then
    echo "No directory selected."
    exit 0
fi

# Change directory to the selected directory
cd "$WORKSPACE_DIR/$SELECTED_DIR" || exit 1
