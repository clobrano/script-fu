#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

ORGFIELPATH=~/Me/Orgmode/Orgmode.org
command -v notify-send >/dev/null
if [ $? -eq 0 ]; then
    NOTIFY="notify-send"
else
    NOTIFY="echo"
fi


# Function to estimate reading time and categorize it
calculate_reading_time() {
    word_count=$(echo "$1" | wc -w)
    reading_speed=200  # Average reading speed in words per minute
    reading_time=$((word_count / reading_speed))
    reading_time=$((reading_time + 1))  # Add 1 minute to round up

    if [ "$reading_time" -le 10 ]; then
        duration_tag="short"
    elif [ "$reading_time" -le 20 ]; then
        duration_tag="mid"
    else
        duration_tag="long"
    fi

    echo "$reading_time" "$duration_tag"
}

# Function to process a YouTube URL and categorize it
process_youtube() {
    url=$1

    info=$(yt-dlp --get-title --get-duration "$url")
    title=$(echo "$info" | sed -n '1p')
    duration=$(echo "$info" | sed -n '2p')

    grep "$url" ${ORGFIELPATH} >/dev/null
    if [ $? -eq 0 ]; then
        $NOTIFY "$title already in ReadItLater"
        return 0
    fi

    # Convert duration to seconds
    duration_seconds=$(echo "$duration" | awk -F: '{ if (NF==3) { print ($1 * 3600) + ($2 * 60) + $3 } else if (NF==2) { print ($1 * 60) + $2 } else { print $1 } }')
    duration_minutes=$((duration_seconds / 60))

    if [ "$duration_minutes" -le 10 ]; then
        duration_tag="short"
    elif [ "$duration_minutes" -le 20 ]; then
        duration_tag="mid"
    else
        duration_tag="long"
    fi

    echo -e "* $title :video:$duration_tag:\n  $url\n  duration: $duration" >> ${ORGFIELPATH}
    $NOTIFY "$title saved in ReadItLater"
}

# Function to process a web page URL and categorize it
process_webpage() {
    url=$1
    content=$(curl -sL "$url" | html2text)
    title=$(echo "$content" | head -n 1)

    grep "$url" ${ORGFIELPATH} >/dev/null
    if [ $? -eq 0 ]; then
        $NOTIFY "$title already in ReadItLater"
        return 0
    fi

    reading_info=$(calculate_reading_time "$content")
    reading_time=$(echo "$reading_info" | awk '{print $1}')
    duration_tag=$(echo "$reading_info" | awk '{print $2}')

    echo -e "* $title :reading:$duration_tag:\n  $url\n  duration: ${reading_time}" >> ${ORGFIELPATH}
    $NOTIFY "$title saved in ReadItLater"
}

# Main script logic
if [[ $# -eq 0 ]]; then
    url=`wl-paste`
else
    url=$1
fi

# Check if the URL is a YouTube link
if [[ "$url" =~ "youtube.com" || "$url" =~ "youtu.be" ]]; then
    process_youtube "$url"
else
    process_webpage "$url"
fi
