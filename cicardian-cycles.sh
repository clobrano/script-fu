#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
echo "90 min cycles"
b1=`date +%H:%M`
b2=`date --date "+90 min" +%H:%M`
b3=`date --date "+180 min" +%H:%M`
b4=`date --date "+270 min" +%H:%M`
b5=`date --date "+360 min" +%H:%M`
b5=`date --date "+450 min" +%H:%M`
b6=`date --date "+540 min" +%H:%M`

echo "1st) $b1 - $b2"
echo "2st) $b2 - $b3"
echo "3st) $b3 - $b4"
echo "4st) $b4 - $b5"
echo "5st) $b5 - $b6"
