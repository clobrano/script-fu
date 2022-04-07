#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

testlist=" test-common-helpers test-pco test-charsets test-error-helpers test-modem-helpers test-sms-part-3gpp test-sms-part-cdma test-shared-telit test-plugin-generic test-keyfiles "


pushd ~/workspace/telit/ModemManager

find . \( -iname "*.h" -or -iname "*.c" \) | entr -c tmux-tdd.sh --name "ModemManager" --run "sudo meson test -C build ${testlist}"

popd

tmux-tdd.sh --clean
