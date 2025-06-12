#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
: "${ME:="$HOME/Me"}"

if ! which html2text>/dev/null; then
    echo "[!] html2text is missing!"
fi
if ! which pup 2>/dev/null; then
    go install github.com/ericchiang/pup@latest
fi

ORG_FILEPATH=$ME/Orgmode/ReadItLater.org
ORG_ARCHIVE_FILEPATH=("$ME/Orgmode/ReadItLater.org_archive" "$ME/Orgmode/Orgmode.org_archive")

# Default notification system is stdout
NOTIFY="echo"
WARNING="echo [!]"


if command -v termux-notification > /dev/null; then
    NOTIFY="termux-notification --content"
    WARNING="termux-notification --content"
elif command -v notify-send >/dev/null; then
        NOTIFY="notify-send --app-name ReadItLater -i dialog-information"
        WARNING="notify-send --app-name ReadItLater -i dialog-information"
fi

get_tags() {
    if command -v termux-setup-storage >/dev/null; then
        if ! TAG=$(termux-dialog text -t "ReadItLater" -i "Tags separated by \":\"" | jq -r .text); then
            return 1
        fi
    elif command -v kdialog >/dev/null; then
        if ! TAG=$(kdialog --title ReadItLater --inputbox "Tags (separated by \":\")"); then
            return 1
        fi
    else
        echo ""
        return 1
    fi

    # strip trailing space
    TAG="${TAG% }"

    if [ -z "$TAG" ] || [ "$TAG" == "" ]; then
        return 1
    fi
    echo "$TAG:"
    return 0
}

get_video_data() {
    local url="$1"
    local html title duration author

    html=$(curl -sL "$url")
    title=$(echo "$html" | grep -oP '(?<=<title>)(.*?)(?=</title>)' | sed 's/ - YouTube$//' | head -n1)
    duration=$(echo "$html" | grep -oP '"lengthSeconds":"\K\d+' | head -n1)
    author=$(echo "$html" | grep -oP '(?<="ownerChannelName":")[^"]+')

    # Optional: convert seconds to mm:ss
    local min=0
    if [[ -n "$duration" ]]; then
        min=$((duration / 60))
    fi

    echo "$min,$title $author"
}

check_duplicate() {
    local url=$1

    if grep "$url" "$ORG_FILEPATH" >/dev/null; then
        $WARNING "Already in ReadItLater"
        return 1
    fi
    for archive in "${ORG_ARCHIVE_FILEPATH[@]}"; do
        if grep "$url" "$archive" >/dev/null; then
            $WARNING "Already in ReadItLater Archive"
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
    elif [ "$reading_time" -le 30 ]; then
        duration_tag="mid"
    else
        duration_tag="long"
    fi

    echo "$reading_time" "$duration_tag"
}

# Function to process a YouTube URL and categorize it
process_youtube() {
    local raw_url=$1
    # remove GET arguments from url (e.g. t=Xs)
    url=$(echo "$raw_url" | cut -d'&' -f1)

    check_duplicate "$url"
    if [ $? -eq 1 ]; then
        return 0
    fi

    if ! custom_tags=$(get_tags); then
        return $?
    fi

    data=$(get_video_data "$url")
    duration_minutes=$(echo "$data" | cut -d"," -f1 | tr -d ' ')
    duration=$((duration_minutes * 60))

    title=$(echo "$data" | cut -d"," -f2)
    # remove trailing white spaces
    #title=$(echo "$title")
    title="${title% }"

    if [ -z "$title" ] || [ -z "$duration" ]; then
        $WARNING "Could not process link: missing title or duration"
        exit 1
    fi

    if [[ -z $duration ]]; then
        # right now only the playlists don't have duration, so the tag long is appropriate
        duration="0"
        duration_tag="long"
    else
        # Convert duration to seconds
        duration_seconds=$(echo "$duration" | awk -F: '{ if (NF==3) { print ($1 * 3600) + ($2 * 60) + $3 } else if (NF==2) { print ($1 * 60) + $2 } else { print $1 } }')
        duration_minutes=$((duration_seconds / 60))

        if [ "$duration_minutes" -le 10 ]; then
            duration_tag="short"
        elif [ "$duration_minutes" -le 30 ]; then
            duration_tag="mid"
        else
            duration_tag="long"
        fi
    fi

    creation_date=$(date +%F)

    all_tags=":$duration_tag:video:$custom_tags"

    # escape single and double quotes
    title=${title//\"}
    title=${title//\-}


    cat << EOF >> "$ORG_FILEPATH"
* TODO $title $all_tags
  :PROPERTIES:
  :CREATED: ${creation_date}
  :LEN: ${duration_minutes:-0}
  :URL: ${url}
  :COMMENT:
  :END:
  $url

EOF
    $NOTIFY "[$duration_minutes] $title ($all_tags) saved"
}

# Function to process a web page URL and categorize it
process_webpage() {
    set -x
    url=$1

    check_duplicate "$url"
    if [ $? -eq 1 ]; then
        return 0
    fi

    if ! custom_tags=$(get_tags); then
        return 1
    fi

    title=$(curl -s "$url" | pup 'title text{}')
    content=$(curl -sL "$url" | html2text)
    reading_info=$(calculate_reading_time "$content")
    reading_time=$(echo "$reading_info" | awk '{print $1}')
    duration_tag=$(echo "$reading_info" | awk '{print $2}')
    creation_date=$(date +%F)


    all_tags=":$duration_tag:reading:$custom_tags"

    cat << EOF >> "$ORG_FILEPATH"
* TODO $title $all_tags
  :PROPERTIES:
  :CREATED: ${creation_date}
  :LEN: ${reading_time:-0}
  :URL: ${url}
  :COMMENT:
  :END:
  $url

EOF
    $NOTIFY "[${reading_time}m] $title ($all_tags) saved"
}

# Main script logic
if [ ! -f "$ORG_FILEPATH" ]; then
    $WARNING "Could not find :$ORG_FILEPATH:"
    exit 1
fi
if [[ $# -eq 0 ]]; then
    url=$(wl-paste)
else
    url=$1
fi

if [[ ! $url =~ "http"  ]] && [[ ! $url =~ "www"  ]]; then
    exit 0
fi

# Check if the URL is a YouTube link
if [[ "$url" =~ "youtube.com" || "$url" =~ "youtu.be" ]]; then
    process_youtube "$url"
else
    process_webpage "$url"
fi
