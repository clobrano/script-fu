#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## This script summarizes content from a URL copied to the clipboard. It checks if the clipboard content is a URL and, if so, processes it, redirecting the output to a temporary file.
SUBMITTED=$(wl-paste)
if ! echo "$SUBMITTED" | grep -E "http|https" > /dev/null 2>&1; then
    agent-alert.sh "Summarizer: the clipboard content is not a link"
    exit 0
fi
# Redirect to a file, so that I can run the script in background and read the result asynchronously
OUTFILE=/tmp/summary.md
{
    echo "$SUBMITTED"
    echo "---"
} #> "$OUTFILE"
gemini --prompt "Role: You are an expert content analyst specializing in synthesizing information for executive review. Task: Analyze the content from the provided URL and generate a structured summary. The summary must be clear, concise, and follow the format specified below. Format: Provide a one-paragraph, concise (100 words max) summary. Give a potential reader enough information to decide if they are interested in the full content. Create a bulleted list of the most important topics, concepts, or arguments discussed in the content. List a maximum of 10 key topics. * Each topic should be clear and succinct. Detailed Summary --- $SUBMITTED" #>> "$OUTFILE"
agent-alert.sh "Summarizer ready on $OUTFILE"


  
