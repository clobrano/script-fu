#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
sid=`loginctl --no-legend | cut -c1`
loginctl show-session $sid -p Type
