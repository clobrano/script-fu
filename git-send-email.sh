#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
if [[ $1 = "usb-serial" ]]; then
echo "git send-email --annotate \
--to=\"Johan Hovold <johan@kernel.org>\" \
--to=\"Greg Kroah-Hartman <gregkh@linuxfoundation.org>\" \
--cc=\"linux-usb@vger.kernel.org\" \
$1"
fi

if [[ $1 = "net" ]]; then
echo "git send-email --annotate \
--to=\"Bjørn Mork <bjorn@mork.no>\" \
--to=\"David S. Miller <davem@davemloft.net>\" \
--to=\"Jakub Kicinski <kuba@kernel.org>\" \
--cc=\"netdev@vger.kernel.org\" \
--cc=\"linux-usb@vger.kernel.org\" \
$1"
fi
 
