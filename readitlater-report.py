#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vi: set ft=python :
from datetime import datetime, timedelta
from orgparse import load

# root = loads('''
# * DONE Heading          :TAG:
  # CLOSED: [2012-02-26 Sun 21:15] SCHEDULED: <2012-02-26 Sun>
  # CLOCK: [2012-02-26 Sun 21:10]--[2012-02-26 Sun 21:15] =>  0:05
  # :PROPERTIES:
  # :Effort:   1:00
  # :OtherProperty:   some text
  # :END:
  # Body texts...
# ''')
# node = root.children[0]
# print(node.heading)
# print(node.scheduled)
# print(node.closed)
# print(node.clock)
# print(bool(node.deadline))
# print(node.tags == set(['TAG']))
# print(node.get_property('Effort'))
# print(node.get_property('UndefinedProperty'))
# print(node.get_property('OtherProperty'))
# print(node.body)


def get_monday_from_date_in_same_week(date: datetime) -> datetime:
    """ Given a date, return the Monday date of the same week"""
    return date - timedelta(days=date.weekday())


def get_sunday_from_date_in_same_week(date: datetime) -> datetime:
    """ Given a date, return the Sunday date of the same week"""
    monday = get_monday_from_date_in_same_week(date)
    return monday + timedelta(days=6)


today = datetime.today()
monday = get_monday_from_date_in_same_week(today)
sunday = get_sunday_from_date_in_same_week(today)
print(f"## Readitlater from {monday.strftime("%Y-%M-%d")} to {sunday.strftime("%Y-%M-%d")}\n")
root = load('/home/clobrano/Me/Orgmode/ReadItLater.org')

for node in root[1:]:
    if node.todo != "DONE":
        continue
    closed = node.closed.start
    if monday <= closed <= sunday:
        headline = f"* {node.heading} - {node.tags}"
        print(headline)
print("---")



