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
# Use a regular expression to extract the hash (UUID)
hash=$(echo "$description" | grep -oE '[a-f0-9]{8}(-[a-f0-9]{4}){3}-[a-f0-9]{12}|[a-f0-9]{8}')
is_task=$(echo "$description" | grep -c "#W")

for ctx in "wk" "me"; do
    TASK="task"
    if [ "$ctx" = "wk" ]; then
        TASK="task rc:~/.taskworkrc"
    fi

    if [ -n "$hash" ]; then
        task_description=$($TASK "$hash" export | jq -r '.[0].description')
        if [ -z "$task_description" ] || [ "$task_description" = "null" ]; then
            continue
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

        if [ "$is_task" -eq 1 ]; then
            description="$task_description"
        fi

        lets goto "$description" "$PROJECT" "$ld_tags" "$hash"
        exit $?
    fi
done

# no taskwarrior task found, start a letsdo session with the input description
$cmd
