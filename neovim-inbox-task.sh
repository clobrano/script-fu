#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -eu

noteDirectory="$ME/Notes"
noteFilename="${noteDirectory}/index.md"

nvim -c '/Inbox/+1put =\"* [ ] \" | normal A' "${noteDirectory}/index.md"
