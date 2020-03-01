#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vi: set ft=python :
import sys
import argparse
import os
import datetime
from operator import itemgetter


def active_review(directory, report):
    """ parse a directory of notes and writes a active review report"""
    notes = [
        {
            "name": entry,
            "date": str(
                datetime.datetime.fromtimestamp(
                    os.path.getmtime(os.path.join(directory, entry))
                )
            ).split(".")[0],
        }
        for entry in os.listdir(directory)
        if os.path.isfile(os.path.join(directory, entry))
    ]

    reports = []
    for entry in sorted(notes, key=itemgetter("date")):
        note = entry["name"]
        date = entry["date"]

        path = os.path.join(directory, note)
        reports.append("# [%s] %s" % (date, note.split(".")[0]))
        fh = open(path)
        reports.extend(
            [
                line.strip().replace("##", "\t-").replace("#", "-")
                for line in fh
                if line.startswith("#")
            ]
        )
        reports.append("\n")

    rh = open(report, "w")
    for r in reports:
        rh.write("%s\n" % r)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--directory", "-d", default=".", help="directory containing all the notes"
    )
    parser.add_argument(
        "--report",
        "-r",
        default="active-review-state.md",
        help="name of the report file",
    )
    opts = parser.parse_args()

    active_review(opts.directory, opts.report)
