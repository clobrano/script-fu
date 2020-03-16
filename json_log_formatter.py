#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vi: set ft=python :
"""
Parses the json formatted output of a process and format it in a more readable way

usage:
    json_log_formatter.py <command>

e.g.
    json_log_formatter.py "uxfp -f <stream> --json"                     # no filter
    json_log_formatter.py "uxfp -f <stream> --json" --filter LOG        # only LOG json messages
    json_log_formatter.py "uxfp -f <stream> --json" --filter LOG REPORT # only LOG and REPORT
"""

import sys
import subprocess
import json
import argparse


def execute(cmd):
    """ execute command """
    popen = subprocess.Popen(cmd, stdout=subprocess.PIPE, universal_newlines=True)
    for stdout_line in iter(popen.stdout.readline, ""):
        yield stdout_line
    popen.stdout.close()
    return_code = popen.wait()
    if return_code:
        raise subprocess.CalledProcessError(return_code, cmd)


def sanitize(string):
    """ sanitize a string before JSON-ize it """
    return string.strip().replace("//", "")    # slash replace is only needed on Windows


if __name__ == "__main__":
    PARSER = argparse.ArgumentParser(usage=__doc__)
    PARSER.add_argument("command", help="the command to execute (enclosed in quotes)")
    PARSER.add_argument(
        "-f", "--filter", default=[], nargs="*", help="filter by json type (LOG, PROGRESS, REPORT)"
    )
    OPTS = PARSER.parse_args()

    if len(sys.argv) == 1:
        print(__doc__)
        sys.exit(1)

    FILTERS = ["LOG", "REPORT", "PROGRESS"]
    for f in OPTS.filter:
        if f not in FILTERS:
            print("ERR: unrecognized filter name '{}'. Valid values {}".format(f, FILTERS))
            sys.exit(1)

    for p in execute(sys.argv[1].split()):
        json_object = json.loads(sanitize(p))

        if not OPTS.filter or json_object["type"] in OPTS.filter:
            formatted_json = json.dumps(json_object, indent=2)
            print(formatted_json)
