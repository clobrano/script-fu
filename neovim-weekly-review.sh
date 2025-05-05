#!/usr/bin/env bash

# -*- coding: UTF-8 -*-
: "${ME:=$HOME/Me}"
TAGS="fit rel dty fun skill fin give"

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

count_notes() {
    local path=$1
    if [ ! -f "$path" ]; then
        echo 0
    else
        grep -c '^[\*\+-]' "$path"
    fi
}

count_positive_notes() {
    local path=$1
    if [ ! -f "$path" ]; then
        echo 0
    else
        grep -c '^+' "$path"
    fi
}

positive_notes() {
    local path=$1
    if [ -f "$path" ]; then
        grep '^+ ' "$path"
    fi
}

count_learnittoday() {
    local path=$1
    if [ -f "$path" ]; then
        grep -c '^[\*\+-] #til' "$path"
    fi
}

declare -A overall_tagged_notes
count_tagged_notes() {
    local path=$1

    if [ ! -f "$path" ]; then
        return
    fi

    for tag in $TAGS; do
        count=$(grep -c "+${tag}" "$path")
        overall_tagged_notes[$tag]="$count"
        echo -n "${tag^^}:$count, "
    done
    echo ""
}

count_tagged_notes_overall() {
    local path=$1
    declare -A overall_tagged_notes

    if [ ! -f "$path" ]; then
        return
    fi

    for tag in $TAGS; do
        count=$(grep -c "+${tag}" "$path")
        overall_tagged_notes[$tag]="$count"
        echo -n "${tag^^}:$count, "
    done
    echo ""
}

key_notes() {
    # notes to report in weekly regardless being neutral, positive or negative
    local path=$1
    if [ -f "$path" ]; then
        grep -E 'KEY:' "$path"
    fi
}


# TODO: that might be wrong, but on 2025-01-01 `date +%W` returns "00", while
# the right value is 01
if [ "$week_no" = "00" ]; then
    week_no="01"
fi

# Remove leading 0
week_no=${week_no#0}

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
FILE_NAME="$(date +%Y)-$(date +%m).md"


# Monthly review
{
echo "# $(date +'%Y %B') review"

for day in $(seq -w 1 31); do
    file="$NOTE_PATH/$(date +%Y)-$(date +%m)-$day.md"
    if [ -f "$file" ]; then
        if out=$(sed -n '/#weeklyreview/,/^[^#]+/p' "$file"); then
            if [ -n "$out" ]; then
                dd="$(date +%Y)-$(date +%m)-$day"
                echo -e "\n[[$(date -d "$dd" +'%Y-%m-%d')]] $(date -d "$dd" +%A)"
                echo "$out"
            fi
        fi
    fi
done

} >  "$NOTE_PATH/$(date +%Y)-$(date +%m).md"

# Just logging
echo "updating review between $(date -d @"$start_date_sec" +%F) and $(date -d @"$end_date_sec" +%F) in Week:$(basename "$WEEKLY_PATH") and Month:$FILE_NAME files"

# -------------------------------------------------------------------------------------------------
# Here start writing the file from scratch (note the override ">" at the end of this first section)
# -------------------------------------------------------------------------------------------------

# Weekly note header
{
echo "# Week $(date -d @"$start_date_sec" +%V) ($(date -d @"$start_date_sec" +%F) - $(date -d @"$end_date_sec" +%F)) review"
echo
} > "$WEEKLY_PATH"

# Weekly review
{
echo "## Daily notes"
week_notes=0
week_notes_til=0

current=$start_date_sec
while [ "$current" -le "$end_date_sec" ]; do
    day=$(date -d "@$current" +%F)

    normal=$(count_notes "$NOTE_PATH/$day.md")
    pos=$(count_positive_notes "$NOTE_PATH/$day.md")
    til=$(count_learnittoday "$NOTE_PATH/$day.md")
    tagged=$(count_tagged_notes "$NOTE_PATH/$day.md")

    all=$((normal + pos))
    week_notes=$((week_notes + all))
    week_notes_til=$((week_notes_til + til))
    echo
    echo "[[$day]]: $all notes, POS:$pos, $tagged "
    if [ "$pos" -gt 0 ]; then
        positive_notes "$NOTE_PATH/$day.md"
    fi

    key_notes "$NOTE_PATH/$day.md"
    current=$((current + ONE_DAY_IN_SECONDS))
done
echo
} >> "$WEEKLY_PATH" 

# I want this in the weekly note AND visible when generating the report
echo "Overall: $week_notes notes, $week_notes_til til " | tee -a "$WEEKLY_PATH"
echo "${overall_tagged_notes[*]}"
for tag in "${overall_tagged_notes[@]}"; do
    count=${overall_tagged_notes["$tag"]}
    echo -n "${tag^^}:$count, "
done
echo -e "\n---\n\n" >> "$WEEKLY_PATH"

# Weekly readitlater
{
if command -v termux-setup-storage > /dev/null; then
    python "$HOME"/workspace/script-fu/readitlater-report.py "$week_no" "$year"
else
    readitlater-report.py "$week_no" "$year"
fi
} >>  "$WEEKLY_PATH"


