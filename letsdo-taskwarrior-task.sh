#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -x
# description is a task description in the form of "<some random description> [hash]"
# if [hash] is present, this script is expected to look for a corresponding task and start
# a letsdo activity using its description and project. Otherwise, it will start a
# letsdo activity with the original input description
description=$@
# default cmd uses input description for letsdo
cmd="lets goto $description"
# Use a regular expression to extract the hash (UUID)
hash=$(echo "$description" | grep -oE '[a-f0-9]{8}(-[a-f0-9]{4}){3}-[a-f0-9]{12}|[a-f0-9]{8}')

for ctx in "wk" "me"; do
    TASK="task"
    if [ "$ctx" = "wk" ]; then
        TASK="task rc:~/.taskworkrc"
    fi

    if [ -n "$hash" ]; then
        task_description=$($TASK $hash export | jq -r '.[0].description')
        if [ -z "$task_description" -o "$task_description" = "null" ]; then
            continue
        fi

        project=$($TASK $hash export | jq -r '.[0].project')
        if [ "$project" != "null" ]; then
            PROJECT="@$project"
        fi

        tw_tags=$($TASK $hash export | jq -r '.[0].tags')
        if [ $? -eq 0 -a -n "$tw_tags" -a  "$tw_tags" != "null" ]; then
            tw_tags=$($TASK $hash export | jq -r '.[0].tags[]')
            ld_tags=""

            for tw_tag in ${tw_tags}; do
                ld_tags+="#$tw_tag "
            done
        fi

        lets goto $task_description $PROJECT $ld_tags +$ctx
        exit 0
    fi
done

# no taskwarrior task found, start a letsdo session with the input description
$cmd
