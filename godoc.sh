#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
query=$(echo "$@" | sed 's/ /%20/g')

xdg-open https://pkg.go.dev/search?q=${query}
