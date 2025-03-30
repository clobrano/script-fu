#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vi: set ft=python :
import os
from pathlib import Path
import argparse
from datetime import datetime, timedelta
from orgparse import load

def get_monday_of_week(week: int, year: int) -> datetime:
    monday = datetime.fromisocalendar(year, week, 1)  # 1 = Monday
    return monday.replace(hour=0, minute=0, second=0)


def get_sunday_from_monday(date: datetime) -> datetime:
    sunday = date + timedelta(days=6)
    return sunday.replace(hour=23, minute=59, second=59)


def get_monday_from_date_in_same_week(date: datetime) -> datetime:
    """ Given a date, return the Monday date of the same week"""
    monday = date - timedelta(days=date.weekday())
    return monday.replace(hour=0, minute=0, second=0)


def get_sunday_from_date_in_same_week(date: datetime) -> datetime:
    """ Given a date, return the Sunday date of the same week"""
    monday = get_monday_from_date_in_same_week(date)
    sunday = monday + timedelta(days=6)
    return sunday.replace(hour=23, minute=59, second=59)


def main(week: int, year: int, input_file:Path):
    # today = datetime.today()
    monday = get_monday_of_week(week, year)
    sunday = get_sunday_from_monday(monday)
    monday_str = monday.strftime("%Y-%m-%d")
    sunday_str = sunday.strftime("%Y-%m-%d")
    week_no_str = monday.strftime("%V")
    print(f"## Readitlater W{week_no_str} from {monday_str} to {sunday_str}\n")
    if not input_file.exists():
        print(f"could not find {input_file}")
        return

    root = load(input_file.resolve())

    for node in root[1:]:
        if node.todo != "DONE":
            continue
        closed = node.closed.start
        if monday <= closed <= sunday:
            headline = f"* {node.heading} - {node.tags}"
            print(headline)


if __name__ == "__main__":
    today = datetime.today()
    today_week = today.isocalendar()[1]
    parser = argparse.ArgumentParser()
    parser.add_argument("week", nargs="?", help="Week number", type=int, default=today_week)
    parser.add_argument("year", nargs="?", help="Year number", type=int, default=today.year)
    args = parser.parse_args()

    ME = os.getenv("ME")
    if not ME:
        ME = os.path.expanduser(os.path.join("~", "Me"))
    input_file = Path(os.path.join(ME, "Orgmode", "ReadItLater.org"))

    main(args.week, args.year, input_file)


