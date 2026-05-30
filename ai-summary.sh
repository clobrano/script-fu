#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## This script summarizes content from a URL copied to the clipboard. It checks if the clipboard content is a URL and, if so, processes it, redirecting the output to a temporary file.
set -eu

APP_NAME="AI Summary"
ARTIFACT_PATH="/tmp/ai-summary"
SUMMARY_DEST=${SUMMARY_DEST:=/tmp/ai-summary.txt}

notification() {
    local message="$*"
    notify-send --app-name "$APP_NAME" "$message"
}

URL=${1:=$(wl-paste)}
if ! echo "$URL" | grep -E "http|https" > /dev/null 2>&1; then
    notification "The clipboard content is not a URL link"
    exit 0
fi

for app in yt-dlp whisper; do
    if ! command -v "$app" >/dev/null 2>&1; then
        notification "$app is not installed"
        exit 1
    fi
done

if [ ! -f "$SUMMARY_DEST" ]; then
    if ! mkdir -p "$(dirname "$SUMMARY_DEST")"; then
        notification "could not create directory for $(dirname "$SUMMARY_DEST")"
        exit 1
    fi
    if ! touch "$SUMMARY_DEST"; then
        notification "could not create file $SUMMARY_DEST"
        exit 2
    fi
fi

# Gemini CLI does not have access to youtube links, at least in inline mode
notification "Downloading the audio..."
yt-dlp -x -o "$ARTIFACT_PATH" --audio-format mp3 "$URL"

notification "Transcribing (it might take a while)..."
# this will create a "/tmp/ai-summary.txt file"
whisper "$ARTIFACT_PATH".mp3 --output_format txt --output_dir /tmp

if command -v gemini; then
    pushd /tmp || exit 1
    notification "Summarizing..."
    # whisper should create the following file
    gemini "Role: You are an expert content analyst specializing in synthesizing information for executive review. Task: Analyze the content from the provided /tmp/ai-summary.txt and generate a structured summary. The summary must be clear, concise, and follow the format specified below. Format: infer 2 tags among (skill, finance, fun, news, AI), then write a one-paragraph, concise (100 words max) summary. Give a potential reader enough information to decide if they are interested in the full content. Create a bulleted list of the most important topics, concepts, or arguments discussed in the content. List a maximum of 10 key topics. * Each topic should be clear and succinct. Detailed Summary" >> "$SUMMARY_DEST"
    popd || exit 1
fi

echo "link: $URL" >> "$SUMMARY_DEST"

notification "Transcript ready at: $SUMMARY_DEST"
