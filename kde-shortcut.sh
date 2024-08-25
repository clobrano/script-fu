#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Make use of ww-run-or-raise [1] to create shortcuts for applications
## [1]: https://github.com/academo/ww-run-raise
##

declare -A apps
apps[browser]="ww -fa firefox -c firefox"
apps[terminal]="ww -fa alacritty"
apps[note]="ww -fa konsole -c konsole"

cmd=${apps["$1"]}
echo $cmd
$cmd
