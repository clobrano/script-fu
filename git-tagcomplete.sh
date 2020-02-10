#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to create a annotated tag and pushing it remotely.
## This script also allows to delete a remotely pushed tag
## usage:
##      git-tagcomplete.sh --tag <version> --message <message> [--branch]
##      git-tagcomplete.sh --delete --tag <version>
## options:
##      -t, --tag <version>        Tag version (e.g. v1.0.0)
##      -m, --message <message>    Quoted annotation message
##      -b, --branch <branchname>  Branch name target of the tag
##      -c, --commit <commit>      Specific tag to commit
##      -d, --delete               Delete given tag both remotely and locally
##      -r, --dryrun               Just shows the commands used to create/delete the tag

# GENERATED_CODE: start

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--tag") set -- "$@" "-t";;
"--message") set -- "$@" "-m";;
"--branch") set -- "$@" "-b";;
"--commit") set -- "$@" "-c";;
"--delete") set -- "$@" "-d";;
"--dryrun") set -- "$@" "-r";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hdrt:m:b:c:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        d) _delete=1 ;;
        r) _dryrun=1 ;;
        t) _tag=$OPTARG ;;
        m) _message=$OPTARG ;;
        b) _branch=$OPTARG ;;
        c) _commit=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# GENERATED_CODE: end

dryrun=''
[ ! -z $_dryrun ] && dryrun=echo && echo dry run: commands will have no effect

set -e
if [ -z $_delete ]; then
    if [ -z "$_commit" ]; then
        echo add tag "$_tag"? [press ENTER to continue]
    else
        echo add tag "$_tag" to the following commit?
        echo
        git log "$_commit" -1
        echo [press ENTER to continue]
    fi
    read
    [ ! -z "$_message" ] && annotation="-m $_message" || annotation=
    set -x
    $dryrun git tag -a $_tag $annotation $_commit
    $dryrun git push origin $_tag
    set +x
else
    echo are you sure to delete tag "$_tag" [press ENTER to continue]?
    read
    set -x +e
    $dryrun git push --delete origin $_tag
    $dryrun git tag --delete $_tag
    set +x
fi

