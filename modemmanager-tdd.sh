#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

testlist="test-common-helpers test-pco test-charsets test-error-helpers test-modem-helpers test-sms-part-3gpp test-sms-part-cdma test-shared-telit test-plugin-generic test-keyfiles"
testlist="test-qcdm test-common-helpers test-pco test-at-serial-port test-charsets test-error-helpers test-kernel-device-helpers test-modem-helpers test-sms-part-3gpp test-sms-part-cdma test-udev-rules test-qcdm-serial-port test-modem-helpers-qmi test-shared-icera test-shared-sierra test-shared-telit test-shared-xmm test-plugin-altair-lte test-plugin-cinterion test-plugin-generic test-plugin-huawei test-plugin-linktop test-plugin-ericsson-mbm test-plugin-quectel test-plugin-simtech test-plugin-thuraya test-plugin-ublox test-udev-rules test-keyfiles"

pushd ~/workspace/telit/ModemManager

find . \( -iname "*.h" -or -iname "*.c" \) | entr -c tmux-tdd.sh --name "ModemManager" --run "sudo meson test -C build ${testlist}"

popd

tmux-tdd.sh --clean
