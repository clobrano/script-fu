#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -ux

### CUSTOM Claude CONFIGURATION ###
if [ -f "$HOME/Documents/unsharable" ]; then
    #shellcheck disable=SC1091
    source "$HOME/Documents/unsharable"
    #shellcheck disable=SC1091
    source claude-config.sh
fi

# check dependencies
DEPENDENCIES=(
    gh
    notify-send
    claude
)
for dep in "${DEPENDENCIES[@]}"; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        echo "[!] $dep is missing. Please install and retry"
        exit 1
    fi
done

REVIEW_DEST_ROOT="$HOME/workspace/codeReviews/"
if [[ ! -d "$REVIEW_DEST_ROOT" ]]; then
    echo "I need to create $REVIEW_DEST_ROOT"
    mkdir -p "$REVIEW_DEST_ROOT" || exit 1
fi

# get the pull-request link either from CLI arg or clipboard (expected https://github.com/openshift/cluster-etcd-operator/pull/1523)
PR_LINK=${1:-$(wl-paste)}
PR_NUM=$(basename "$PR_LINK")
# drop number
TRIM_LINK=$(dirname "$PR_LINK")
# drop "pull"
TRIM_LINK=$(dirname "$TRIM_LINK")
PR_PROJ=$(basename "$TRIM_LINK")
# drop project name
TRIM_LINK=$(dirname "$TRIM_LINK")
PR_ORG=$(basename "$TRIM_LINK")

# ensure to remove the temporary directory
TMP_DIR=$(mktemp -d)
trap 'rm -rf $TMP_DIR' SIGINT


pushd "$TMP_DIR" || exit 1
gh repo clone "$PR_ORG/$PR_PROJ" . -- --depth 1

PR_REV_FILE="$REVIEW_DEST_ROOT/$(date +"%F-%H%M%S")-$PR_ORG-$PR_PROJ-PR$PR_NUM.md"
notify-send --app-name "$PR_ORG/$PR_PROJ PR $PR_NUM" "Cloned in $TMP_DIR. Starting review"

claude --print "/review $PR_NUM" > "$PR_REV_FILE"

ACTION_CHOICE=$(notify-send "Review for $PR_ORG/$PR_PROJ PR $PR_NUM ready" "Open the file?" \
    --expire-time=30000 \
    --action="yes=Yes" \
    --action="no=No" \
    --wait)

# The variable $ACTION_CHOICE now holds the NAME of the button clicked ('yes' or 'no').
# We use a case statement to react to the choice.
case "$ACTION_CHOICE" in
    "yes")
        xdg-open "$PR_REV_FILE"
        # Add your command to run for 'Yes' here
        ;;
    *)
        ;;
esac

rm -fr "$TMP_DIR"
