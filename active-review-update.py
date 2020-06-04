#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vi: set ft=python :
"""This module parses markdown files, reporting the
titlename, last modification date and the titles as item list"""

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

        if not note.endswith(".md"):
            continue
        if note == "active-review-state.md" or note == "roadmap.md":
            continue
        path = os.path.join(directory, note)
        reports.append("# [%s] %s" % (date, note.split(".")[0]))
        file_handle = open(path)
        try:
            reports.extend(
                [
                    line.strip().replace("###", "\t\t-").replace("##", "\t-").replace("#", "-")
                    for line in file_handle
                    if line.startswith("#")
                ]
            )
        except UnicodeDecodeError as err:
            print("error parsing file {}".format(note))
            raise err
        reports.append("\n")

    file_handle = open(report, "w")
    for row in reports:
        file_handle.write("%s\n" % row)


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
