#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Make use of ww-run-or-raise [1] to create shortcuts for applications
## [1]: https://github.com/academo/ww-run-raise
##

declare -A apps
apps[browser]="ww -fa Zen -c \"flatpak run io.github.zen_browser.zen\""
apps[note]="ww -f kitty -c kitty"
apps[terminal]="ww -fa konsole -c konsole"
apps[slack]="ww -fa Slack -c \"flatpak run com.slack.Slack\""
apps[whatsapp]="ww -fa ZapZap -c \"flatpak run com.rtosta.zapzap\""

#apps[terminal2]="ww -fa alacritty -c alacritty"
#apps[note]='ww -fa WezTerm'
#apps[browser]="ww -fa Chrome -c \"flatpak run com.google.Chrome\""
#apps[browser]="ww -fa firefox -c firefox"

if ! command -v ww >/dev/null; then
    git clone https://github.com/academo/ww-run-raise ~/Apps/academo-ww-run-raise
    echo "[+] Installing ww under /usr/local/bin"
    sudo cp ~/Apps/academo-ww-run-raise/ww /usr/local/bin
fi

cmd=${apps["$1"]}
set -x
$cmd
