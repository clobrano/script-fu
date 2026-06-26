#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Create a search link for GMail from text
## e.g.
## input: email from HR
## output: https://mail.google.com/mail/u/${WORK_ACCOUNT_ID}/#search/email+from+HR
WORK_ACCOUNT_ID=0
if [ -z "$*" ]; then
    echo "Usage: $0 <search_query>"
    exit 1
fi

# Join all arguments into a single string
SEARCH_QUERY="$*"

# Sanitize the input:
# 1. Remove some problematic characters (e.g. parenthesis)
SEARCH_QUERY=${SEARCH_QUERY//(/}
SEARCH_QUERY=${SEARCH_QUERY//)/}
SEARCH_QUERY=${SEARCH_QUERY//\[/}
SEARCH_QUERY=${SEARCH_QUERY//\]/}
SEARCH_QUERY=${SEARCH_QUERY//:/}
# 2. Replace spaces with '+'
SEARCH_QUERY=${SEARCH_QUERY// /+}
# 3. Remove consecutive '+' characters
while [[ "$SEARCH_QUERY" == *"++"* ]]; do
    SEARCH_QUERY=${SEARCH_QUERY//++/+}
done

echo "https://mail.google.com/mail/u/$WORK_ACCOUNT_ID/#search/${SEARCH_QUERY}" | wl-copy
