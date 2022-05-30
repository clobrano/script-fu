#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Productive time is a script in my tmux configuration
## it is intended to show on tmux the count down to the time
## set in $HOME/.productive-time-deadline, and it is used (by me)
## as reminder that the time to do *SOMETHING IMPORTANT* is limited.
## This script is an helper to let me configure such file in an easier wan
## possibly with some intelligence and natural language processing converting time.

message=$@

result=`date --date="${message}" +%H:%M`
echo [+] setting the deadline to $result. Continue? [ENTER/CTRL-c]
read
echo $result > $HOME/.productive-time-deadline
