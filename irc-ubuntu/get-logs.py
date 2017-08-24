#!/usr/bin/env python
# -*- coding: utf-8 -*-
# vi: set ft=python :
'''
Get Ubuntu IRC logs

usage: get-logs.py [--DATE=DATE] [--channel=channel]

options:
    -c channel, --channel channel   The channel whose logs you want to get [default: ubuntu-desktop]
    -d DATE, --DATE=DATE            The DATE of the logs in format YYYY-MM-DD [default: today]
'''

import urllib2
import datetime
import docopt

OPTS = docopt.docopt(__doc__)

DATE = OPTS['--DATE']
if DATE == 'today':
    DATE = str(datetime.datetime.now()).replace('-', '/').split(' ')[0]
else:
    DATE = DATE.replace('-', '/')

CHANNEL = OPTS['--channel']
URL = 'https://irclogs.ubuntu.com/{DATE}/%23{channel}.txt'.format(DATE=DATE, channel=CHANNEL)
ALERT = False
MESSAGES = []

for line in urllib2.urlopen(URL):
    line = line.rstrip()
    if "lobrano" in line or "carlo" in line:
        alert = True
        MESSAGES.append(line)
    print line

if alert:
    print "\nThere are messages for you"
    for msg in MESSAGES:
        print msg
