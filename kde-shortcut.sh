#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Make use of ww-run-or-raise [1] to create shortcuts for applications
## [1]: https://github.com/academo/ww-run-raise
##

declare -A apps
apps[browser]="ww -fa Zen -c \"flatpak run io.github.zen_browser.zen\""
#apps[browser]="ww -fa firefox -c firefox"
#apps[browser]="ww -fa Chrome -c \"flatpak run com.google.Chrome\""

apps[terminal]="ww -f kitty -c kitty"
apps[terminal2]="ww -f org.wezfurlong.wezterm"
#apps[terminal2]="ww -fa alacritty -c alacritty"

apps[note]="ww -fa konsole -c konsole"
apps[slack]="ww -fa Slack -c \"flatpak run com.slack.Slack\""
apps[whatsapp]="ww -fa ZapZap -c \"flatpak run com.rtosta.zapzap\""


command -v ww >/dev/null
if [[ $? -ne 0 ]]; then
    git clone https://github.com/academo/ww-run-raise ~/Apps/academo-ww-run-raise
    echo "[+] Installing ww under /usr/local/bin"
    sudo cp ~/Apps/academo-ww-run-raise/ww /usr/local/bin
fi

cmd=${apps["$1"]}
#notify-send --app-name WW "$1" "$cmd"
echo $cmd
$cmd
