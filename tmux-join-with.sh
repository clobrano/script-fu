#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
TARGET=$1
CURR_WINDOW_NUMBER=`tmux display-message -p '#I'`
tmux join-pane -s $CURR_WINDOW_NUMBER -t $TARGET
