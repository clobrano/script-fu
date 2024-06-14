#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

export TASKRC=$HOME/.taskworkrc
export TASKDATA=$HOME/Documents/taskwarriorRH

echo "# SUMMARY"
task summary

echo "# ACTIVE"
task +ACTIVE +PENDING

echo "--------------------------------------------------"
echo "     "
echo "     "

echo "# GOOLE TASK"
task tag:email +PENDING

echo "--------------------------------------------------"
echo "     "
echo "     "

echo "# NEXT 14 DAYS"
task due.after:today due.before:14d

echo "--------------------------------------------------"
echo "     "
echo "     "

echo "# TODAY/OVERDUE"
task +OVERDUE +PENDING

echo "--------------------------------------------------"
echo "     "
echo "     "
