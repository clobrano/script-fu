#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

set -x
task.sh end.after:`date -d "last sunday" +%F` and end.before:`date -d "sunday" +%F` completed
