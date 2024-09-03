#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
awk 'NR==1 || index($0, "$@")'
