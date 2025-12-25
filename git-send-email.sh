#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## This script provides instructions and a wrapper for configuring and using `git send-email` to send patches, with special handling for 'usb-serial' related patches.

echo [+] the following is the command to configure send mail.
echo [+] - if you want to sent the last N commits as patches, append "-N" to the command
echo [+] - add -vN flag to send the Nth version of the patch
echo [+] you should also able to pass the *.patch file, but not checked yet


if [[ $1 = "usb-serial" ]]; then
    cmd="git send-email --annotate \
--to=\"Johan Hovold <johan@kernel.org>\" \
--to=\"Greg Kroah-Hartman <gregkh@linuxfoundation.org>\" \
--cc=\"linux-usb@vger.kernel.org\" \
--cc=\"Daniele Palmas <dnlplm@gmail.com>\" "
fi

if [[ $1 = "net" ]]; then
    cmd="git send-email --annotate \
--to=\"Bjørn Mork <bjorn@mork.no>\" \
--to=\"David S. Miller <davem@davemloft.net>\" \
--to=\"Jakub Kicinski <kuba@kernel.org>\" \
--cc=\"netdev@vger.kernel.org\" \
--cc=\"linux-usb@vger.kernel.org\" \
--cc=\"Daniele Palmas <dnlplm@gmail.com>\" "
fi

echo "-- cut here --"
echo "$cmd"
echo "-- cut here --"


echo "[+] rembember -vN for version, sign-off, and changelogs"
