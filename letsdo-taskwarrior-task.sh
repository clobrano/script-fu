#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
#set -x
# description is a task description in the form of "<some random description> [hash]"
# if [hash] is present, this script is expected to look for a corresponding task and start
# a letsdo activity using its description and project. Otherwise, it will start a
# letsdo activity with the original input description
description=$*
# default cmd uses input description for letsdo
cmd="lets goto $description"
# Use a regular expression to extract the hash (UUID) from rounded parentheses
hash=$(echo "$description" | grep -oP '(?<=\()([a-f0-9]{8}(-[a-f0-9]{4}){3}-[a-f0-9]{12}|[a-f0-9]{8})(?=\))' | head -n 1)

TASK="task"
if [ -n "$hash" ]; then
    task_description=$($TASK "$hash" export | jq -r '.[0].description')
    if [ -z "$task_description" ] || [ "$task_description" = "null" ]; then
        echo "no taskwarrior task found, start a letsdo session with the input description"
        $cmd
        exit 0
    fi

    project=$($TASK "$hash" export | jq -r '.[0].project')
    if [ "$project" != "null" ]; then
        PROJECT="@$project"
    fi

    if tw_tags=$($TASK "$hash" export | jq -r '.[0].tags'); then
        if [ -n "$tw_tags" ] && [ "$tw_tags" != "null" ]; then
            tw_tags=$($TASK "$hash" export | jq -r '.[0].tags[]')
            ld_tags=""

            for tw_tag in ${tw_tags}; do
                if [ "$tw_tags" == "meeting" ]; then
                    continue
                fi
                ld_tags+="#$tw_tag "
            done
        fi
    fi

    description="$task_description $ld_tags $PROJECT ($hash)"
    lets goto "$description"
    exit $?
fi


