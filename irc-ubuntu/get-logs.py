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
try:
    from raffaello import Raffaello, parse_request

    REQUEST = r'''
\d+:\d+=>cyan_bold
flexiondotorg=>color007_bold
Laney=>color049_bold
jbicha=>color230_bold
seb128=>yellow_bold
Trevinho=>color120_bold
tsimonq2=>color117_bold
willcooke=>color122_bold
hikiko=>bgcolor019_bold
didrocks=>color111_bold
duflu=>color229_bold
oSoMoN=>color123_bold
kenvandine=>color210_bold
n-m=>yellow_bold
network\smanager=>yellow_bold
m-m=>yellow_bold
clobrano=>green_bold
'''
    RAFFAELLO = Raffaello(parse_request(REQUEST))
except ImportError as error:
    print 'could not colorize output: {}'.format(error)
    RAFFAELLO = None

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
        ALERT = True
        MESSAGES.append(line)
    if RAFFAELLO:
        print RAFFAELLO.paint(line)
    else:
        print line

if ALERT:
    print "\nThere are messages for you"
    for msg in MESSAGES:
        if RAFFAELLO:
            print RAFFAELLO.paint(msg)
        else:
            print msg
