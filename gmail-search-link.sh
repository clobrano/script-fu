#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Create a search link for GMail from text
## e.g.
## input: email from HR
## output: https://mail.google.com/mail/u/0/#search/email+from+HR

if [ -z "$*" ]; then
    echo "Usage: $0 <search_query>"
    exit 1
fi

# Join all arguments into a single string
SEARCH_QUERY="$*"

# Sanitize the input:
# 1. Remove parentheses
SEARCH_QUERY=${SEARCH_QUERY//(/}
SEARCH_QUERY=${SEARCH_QUERY//)/}
# 2. Replace spaces with '+'
SEARCH_QUERY=${SEARCH_QUERY// /+}
# 3. Remove consecutive '+' characters
while [[ "$SEARCH_QUERY" == *"++"* ]]; do
    SEARCH_QUERY=${SEARCH_QUERY//++/+}
done

echo "https://mail.google.com/mail/u/0/#search/${SEARCH_QUERY}"
