#!/usr/bin/env python
# -*- coding: utf-8 -*-
# vi: set ft=python :
'''
Get Ubuntu IRC logs

usage: get-logs.py [--date=date] [--channel=channel]

options:
    -c channel, --channel channel   The channel whose logs you want to get [default: ubuntu-desktop]
    -d date, --date=date            The date of the logs in format YYYY-MM-DD [default: today]
'''
import sys
import docopt
import urllib2
import datetime

opts = docopt.docopt (__doc__)

date = opts['--date']
if date == 'today':
    date = str (datetime.datetime.now ()).replace ('-', '/').split (' ')[0]
else:
    date = date.replace ('-', '/')

channel = opts ['--channel']

url = 'https://irclogs.ubuntu.com/{date}/%23{channel}.txt'.format (date=date, channel=channel)

for line in urllib2.urlopen(url):
    print(line.rstrip())
