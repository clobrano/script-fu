#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

ORG_FILEPATH=~/Me/Orgmode/ReadItLater.org
ORG_ARCHIVE_FILEPATH=("~/Me/Orgmode/ReadItLater_archive.org" "~/Me/Orgmode/Orgmode.org_archive")

command -v notify-send >/dev/null
if [ $? -eq 0 ]; then
    NOTIFY="notify-send --app-name ReadItLater -i dialog-information"
    WARNING="notify-send --app-name ReadItLater -i dialog-warning"
else
    NOTIFY="echo"
    WARNING="echo [!]"
fi


get_tags() {
    command -v kdialog >/dev/null
    if [[ $? -eq 0 ]]; then
        TAG=`kdialog --title ReadItLater --inputbox "Tags (separated by \":\")"`
        echo "$TAG:"
        return 0
    fi
    command -v termux-setup-storage
    if [[ $? -eq 0 ]]; then
        TAG=`termux-dialog text --title "ReadItLater" --hint "Tags separated by \":\""`
        if [[ -z $TAG ]]; then
            echo ""
        else
            echo "$TAG:"
        fi
        return 0
    fi
    echo ""
}


check_duplicate() {
    local url=$1
    grep "$url" ${ORG_FILEPATH} >/dev/null
    if [ $? -eq 0 ]; then
        $WARNING "$title: already in ReadItLater"
        return 1
    fi
    for archive in ${ORG_ARCHIVE_FILEPATH[@]}; do
        grep "$url" $archive >/dev/null
        if [ $? -eq 0 ]; then
            $WARNING "$title: already in ReadItLater Archive"
            return 1
        fi
    done
    return 0
}


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

    check_duplicate "$url"
    if [ $? -eq 1 ]; then
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

    creation_date=`date +%F`

    more_tags=`get_tags`

    echo -e "* $title :video:$duration_tag:$more_tags\n  $url\n  created: [${creation_date}]\n  duration: $duration" >> ${ORG_FILEPATH}
    $NOTIFY "$title saved"
}

# Function to process a web page URL and categorize it
process_webpage() {
    url=$1

    title=$(wget -q -O - "$url" | tr "\n" " " | sed 's|.*<title>\([^<]*\).*</head>.*|\1|;s|^\s*||;s|\s*$||')
    grep "$url" ${ORG_FILEPATH} >/dev/null
    if [ $? -eq 0 ]; then
        $NOTIFY "Skip $title, as it is already in ReadItLater"
        return 0
    fi

    content=$(curl -sL "$url" | html2text)
    reading_info=$(calculate_reading_time "$content")
    reading_time=$(echo "$reading_info" | awk '{print $1}')
    duration_tag=$(echo "$reading_info" | awk '{print $2}')
    creation_date=`date +%F`

    more_tags=`get_tags`

    echo -e "* $title :reading:$duration_tag:$more_tags\n  $url\n  created: [${creation_date}]\n  duration: ${reading_time} min" >> ${ORG_FILEPATH}
    $NOTIFY "$title saved"
}

# Main script logic
if [[ $# -eq 0 ]]; then
    url=`wl-paste`
else
    url=$1
fi

if [[ ! $url =~ "http"  ]]; then
    exit 0
fi

# Check if the URL is a YouTube link
if [[ "$url" =~ "youtube.com" || "$url" =~ "youtu.be" ]]; then
    process_youtube "$url"
else
    process_webpage "$url"
fi
