#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to show notes with chapters tagged for review.
## Notes must be written in markdown, then chapters can be marked
## for review using tag "@@" (the look). This script shows the file
## name and each tagged title. To improve, add a review status mark
## at the end of the title (+/k:good review, -/x:bad review).
## e.g.
##      # Chapter to review @@xxkk
## usage: active-review.sh [--path path/to/dir] [--output /path/to/file]
## options:
##      -p, --path <path> Path to note directory [default: .]
##      -o, --output <path> Path to the file where save the result [default: review.md]
# GENERATED_CODE: start
# Default values
_path=.

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--path") set -- "$@" "-p";;
"--output") set -- "$@" "-o";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hp:o:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        p) _path=$OPTARG ;;
        o) _output=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# GENERATED_CODE: end

# Open STDOUT as $LOG_FILE file for read and write.
cmd=
if [ ! -z $_output ]; then
    exec 1<>$_output
fi

for f in $(ls -tr $_path); do
    if [ $f == $_output ]; then
        continue
    fi
    time=$(stat -c %y $f | cut -d' ' -f1)
    no_matches=$(grep @@ $f | wc -l)

    if [ $no_matches -gt 0 ]; then
        printf "#%s %s\n" $time $f;
        matches=$(grep @@ $f)
        while IFS= read
        do
            echo "-" $REPLY
        done <<< "$matches"
        echo ""
    fi
done
