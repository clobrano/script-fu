#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
task="task rc:~/.taskworkrc"

echo
echo "-------------------- Quarter 1 (Jan-Mar) --------------------"
$task end.after:soy end.before:$(date -d "Apr 1" +%F) quick

echo
echo "-------------------- Quarter 2 (Apr-Jun) --------------------"
$task end.after:$(date -d "Apr 1" +%F) end.before:$(date -d "Jul 1" +%F) quick

echo
echo "-------------------- Quarter 3 (Jul-Sep) --------------------"
$task end.after:$(date -d "Jul 1" +%F) end.before:$(date -d "Oct 1" +%F) quick

echo
echo "-------------------- Quarter 4 (Oct-Dec) --------------------"
$task end.after:$(date -d "Oct 1" +%F) end.before:eoy quick
