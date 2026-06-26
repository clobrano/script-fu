#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -o errexit
set -o pipefail

link=$1

main() {
    verify_input
    convert_into_custom_markdown_pull_request_ref
    convert_into_inline_markdown_weblink
}

verify_input() {
    if [ -z "$link" ]; then
        echo "getting the link from clipboard..."
        if ! link=$(wl-paste); then
            echo "[!] could not get the link from clipboard: error $?"
            exit 1
        fi
        if [ -z "$link" ] || [[ "$link" != https://* ]] ; then
            echo "[!] no link found, something went wrong: clipboard had \"$link\""
            exit 1
        fi
    fi
}

# convert the url https:/a/b/c/d into "[d](URL)"
convert_into_inline_markdown_weblink() {
    link_text=$(basename "$link"| tr '[:punct:]' ' ')
    formatted_string="[$link_text]($link)"
    echo "$formatted_string" | wl-copy
}

# convert github "pull" URL to [org/project PR<num>] and exit, or return
# to let the next function execute
convert_into_custom_markdown_pull_request_ref() {
    org=""
    project=""
    item_num=""
    item_type="" # "PR" or "I"
    formatted_string=""

    if [[ ! "$link" =~ "github" ]]; then
        return
    fi

    if [[ "$link" =~ "pull" ]]; then
        if [[ "$link" =~ https://github.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
            org=${BASH_REMATCH[1]}
            project=${BASH_REMATCH[2]}
            item_num=${BASH_REMATCH[3]}
            item_type="PR"
        fi
    elif [[ "$link" =~ "issue" ]]; then
        if [[ "$link" =~ https://github.com/([^/]+)/([^/]+)/issues/([0-9]+) ]]; then
            org=${BASH_REMATCH[1]}
            project=${BASH_REMATCH[2]}
            item_num=${BASH_REMATCH[3]}
            item_type="I"
        fi
    fi

    if [[ -n "$org" && -n "$project" && -n "$item_num" ]]; then
        # Fetch HTML and extract the title
        # \xC2\xB7 is the UTF-8 encoding for the middle dot '·'
        # This sed command removes " by <author>" and " · (Pull Request|Issue) #<num> · <org>/<project>"
        # The final sed command removes any trailing whitespace
        title=$(curl -s "$link" | grep -oP '(?<=<title>)([^<]+)(?=</title>)' | sed -E 's/( by [^\xC2\xB7]*)?\xC2\xB7 (Pull Request|Issue) #[0-9]+ \xC2\xB7 .*$//' | sed 's/[[:space:]]*$//')

        formatted_string="[${org}/${project} ${item_type}${item_num}]($link) _${title}_"
        echo "$formatted_string"
        echo "$formatted_string" | wl-copy
        exit 0
    fi
}

### MAIN ###
main


