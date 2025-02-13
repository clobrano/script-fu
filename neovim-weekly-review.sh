#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
: "${ME:=$HOME/Me}"

week_no=${1:-$(date +%V)}
year=${2:-$(date +%Y)}

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

# TODO: that might be wrong, but on 2025-01-01 `date +%W` returns "00", while
# the right value is 01
if [ "$week_no" = "00" ]; then
    week_no="01"
fi

start_date=$(week_range "$year" "$week_no" | cut -d" " -f1)
end_date=$(week_range "$year" "$week_no" | cut -d" " -f2)
ONE_DAY_IN_SECONDS=86400
end_date_sec=$(date -d "$end_date" +%s)
if [ -n "$start_date" ]; then
    start_date_sec=$(date -d "$start_date" +%s)
else
    # default to a 7 days window
    ONE_WEEK_IN_SECONDS=$((ONE_DAY_IN_SECONDS * 6))
    start_date_sec=$((end_date_sec - ONE_WEEK_IN_SECONDS))
fi


NOTE_PATH=$ME/Notes/Journal


FILE_NAME=$(date -d @"$start_date_sec" +%Y-%m-W%V).md
WEEKLY_PATH=$NOTE_PATH/$FILE_NAME
FILE_NAME=$(date -d @"$start_date_sec" +%Y-%m).md
MONTHLY_PATH=$NOTE_PATH/$FILE_NAME
echo "updating review between $(date -d @"$start_date_sec" +%F) and $(date -d @"$end_date_sec" +%F) in $FILE_NAME"

count_notes() {
    local path=$1
    if [ ! -f "$path" ]; then
        echo 0
    else
        grep -c -E '^\.\. ' "$path"
    fi
}

count_positive_notes() {
    local path=$1
    if [ ! -f "$path" ]; then
        echo 0
    else
        grep -c -E '^\.\+ ' "$path"
    fi
}

count_negative_notes() {
    local path=$1
    if [ ! -f "$path" ]; then
        echo 0
    else
        grep -c -E '^\.- ' "$path"
    fi
}

positive_notes() {
    local path=$1
    if [ -f "$path" ]; then
        grep -E '^\.\+ ' "$path"
    fi
}

learnittoday() {
    local path=$1
    if [ -f "$path" ]; then
        grep -E '^.. #til' "$path"
    fi
}

key_notes() {
    # notes to report in weekly regardless being neutral, positive or negative
    local path=$1
    if [ -f "$path" ]; then
        grep -E 'KEY:' "$path"
    fi
}


echo "# Week $(date -d @"$start_date_sec" +%V) ($(date -d @"$start_date_sec" +%F) - $(date -d @"$end_date_sec" +%F)) review" > "$WEEKLY_PATH"

week_notes=0
week_notes_pos=0
week_notes_neg=0

current=$start_date_sec
while [ "$current" -le "$end_date_sec" ]; do
    day=$(date -d "@$current" +%F)

    normal=$(count_notes "$NOTE_PATH/$day.md")
    pos=$(count_positive_notes "$NOTE_PATH/$day.md")
    neg=$(count_negative_notes "$NOTE_PATH/$day.md")

    all=$((normal + pos + neg))
    week_notes=$((week_notes + all))
    week_notes_pos=$((week_notes_pos + pos))
    week_notes_neg=$((week_notes_neg + neg))
    echo "" >> "$WEEKLY_PATH"
    echo [["$day"]]: "$all" notes, "$pos"+, "$neg"- >> "$WEEKLY_PATH"
    if [ "$pos" -gt 0 ]; then
        positive_notes "$NOTE_PATH/$day.md" >> "$WEEKLY_PATH"
    fi
    learnittoday "$NOTE_PATH/$day.md" >> "$WEEKLY_PATH"
    key_notes "$NOTE_PATH/$day.md" >> "$WEEKLY_PATH"
    current=$((current + ONE_DAY_IN_SECONDS))
done


echo "" >> "$WEEKLY_PATH"
echo "Overall: $week_notes notes, $week_notes_pos positives, $week_notes_neg negatives" | tee -a "$WEEKLY_PATH"
echo ""; echo "" >> "$WEEKLY_PATH"
echo "## Week goals | due.after:$(date -d @"$start_date_sec" +%F) due.before:$(date -d @"$end_date_sec" +%F)" >>  "$WEEKLY_PATH"

#set -x
{
echo "# $(date +'%Y %B') review"

for day in $(seq -w 1 31); do
    out=$(grep "#weeklyreview" "$NOTE_PATH/$(date +%Y)-$(date +%m)-$day.md" 2>/dev/null)
    if [ $? -eq 0 ]; then
        dd="$(date +%Y)-$(date +%m)-$day"
        echo ""
        echo "[[$(date -d "$dd" +'%Y-%m-%d')]] $(date -d "$dd" +%A)"
        echo "$out" | awk -F"weeklyreview" '{print $2}'
    fi
done

} >  "$MONTHLY_PATH"
