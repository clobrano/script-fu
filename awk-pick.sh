#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Help script to copy into clipboard a token from the output of a command
## Usage: <command> | awk-pick.sh <token number>
## Example: ls -l | awk-pick.sh 9

# Get the token number
TOKEN=$1
awk -v token=$TOKEN '{print $token}' | xclip -selection clipboard
