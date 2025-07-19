#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Make use of ww-run-or-raise [1] to create shortcuts for applications
## [1]: https://github.com/academo/ww-run-raise
##

declare -A apps
apps[browser]="ww -fa Zen -c \"flatpak run io.github.zen_browser.zen\""
apps[chrome]="ww -fa Chrome -c \"flatpak run com.google.Chrome\""
#apps[browser]="ww -fa firefox -c firefox"

apps[terminal]='ww -fa WezTerm'
apps[terminal2]="ww -fa alacritty -c alacritty"
#apps[terminal2]="ww -fa konsole -c konsole"

apps[note]="ww -f kitty -c kitty"
apps[slack]="ww -fa Slack -c \"flatpak run com.slack.Slack\""
apps[whatsapp]="ww -fa ZapZap -c \"flatpak run com.rtosta.zapzap\""


command -v ww >/dev/null
if [[ $? -ne 0 ]]; then
    git clone https://github.com/academo/ww-run-raise ~/Apps/academo-ww-run-raise
    echo "[+] Installing ww under /usr/local/bin"
    sudo cp ~/Apps/academo-ww-run-raise/ww /usr/local/bin
fi

cmd=${apps["$1"]}
echo $cmd
$cmd
