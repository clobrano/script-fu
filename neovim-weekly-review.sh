#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
week_no=$1
year=${2:-`date +%Y`}

week_range() {
    # Thanks to https://stackoverflow.com/a/61733557/1197008
    local _u _F _V
    # dow Jan 01 (Mon 01 ... Sun 07)
    _u="$(date -d "$1-01-01" "+%u")"
    # First Monday
    _F="$(date -d "$1-01-01 + $(( (8 - _u) % 7)) days" "+%F")"
    # Week number of first Monday
    _V="$(date -d "$_F" "+%V")"
    printf -- "%s %s\n" "$(date -d "$_F + $(( 7*($2 - _V) )) days" "+%F")"       \
                        "$(date -d "$_F + $(( 7*($2 - _V) + 6 )) days" "+%F")"
}

start_date=`week_range $year $week_no | cut -d" " -f1`
end_date=`week_range $year $week_no | cut -d" " -f2`

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

    normal=$(count_notes "$NOTE_PATH/$day.md")
    pos=$(count_positive_notes "$NOTE_PATH/$day.md")
    neg=$(count_negative_notes "$NOTE_PATH/$day.md")

    all=$((normal + pos + neg))
    echo "" >> $WEEKLY_PATH
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
