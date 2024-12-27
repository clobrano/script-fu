#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
end_date=$1
start_date=$2

ONE_DAY_IN_SECONDS=86400

end_date_sec=$(date -d "$end_date" +%s)
if [ -n "$start_date" ]; then
    start_date_sec=$(date -d "$start_date" +%s)
else
    # default to a 7 days window
    ONE_WEEK_IN_SECONDS=$(($ONE_DAY_IN_SECONDS*6))
    start_date_sec=$((end_date_sec - $ONE_WEEK_IN_SECONDS))
fi

echo "review between $(date -d @$start_date_sec +%F) and $(date -d @$end_date_sec +%F)"

NOTE_PATH=$ME/Notes/Journal
WEEKLY_PATH=$NOTE_PATH/$(date -d @$start_date_sec +%Y-%m-W%V).md

count_notes() {
    local path=$1
    if [ ! -f $path ]; then
        echo 0
    else
        echo $(grep -E '^\.\. ' $path | wc -l)
    fi
}

count_positive_notes() {
    local path=$1
    if [ ! -f $path ]; then
        echo 0
    else
        echo $(grep -E '^\.\+ ' $path | wc -l)
    fi
}

count_negative_notes() {
    local path=$1
    if [ ! -f $path ]; then
        echo 0
    else
        grep -E '^\.- ' $path | wc -l
    fi
}

positive_notes() {
    local path=$1
    if [ -f $path ]; then
        grep -E '^\.\+ ' $path
    fi
}

learnittoday() {
    local path=$1
    if [ -f $path ]; then
        grep -E '^.. #til' $path
    fi
}

echo "# Week $(date -d @$start_date_sec +%V) ($(date -d @$start_date_sec +%F) - $(date -d @$end_date_sec +%F)) review" > $WEEKLY_PATH
echo "" >> $WEEKLY_PATH

current=$start_date_sec
while [ "$current" -le "$end_date_sec" ]; do
    day=$(date -d "@$current" +%F)

    all=$(count_notes "$NOTE_PATH/$day.md")
    pos=$(count_positive_notes "$NOTE_PATH/$day.md")
    neg=$(count_negative_notes "$NOTE_PATH/$day.md")

    echo [[$day]]: $all notes, $pos+, $neg- >> $WEEKLY_PATH
    if [ $pos -gt 0 ]; then
        positive_notes "$NOTE_PATH/$day.md" >> $WEEKLY_PATH
        learnittoday "$NOTE_PATH/$day.md" >> $WEEKLY_PATH
    fi
    current=$((current + ONE_DAY_IN_SECONDS))
done

echo "" >> $WEEKLY_PATH
echo "" >> $WEEKLY_PATH
echo "## propositi | tag:weekgoal due.after:$(date -d @$start_date_sec +%F) before:$(date -d @$end_date_sec +%F)" >>  $WEEKLY_PATH
