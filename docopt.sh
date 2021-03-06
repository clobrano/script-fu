#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Helper script to autogenerate getopts code out of the target script's help message
## The script must contain a usage description with '##' at the beginning of each line (that is, like this one)
##
##      usage: getopt.sh [options]
##
##      options:
##           -s <script_path> The path to the script to be parsed
##           -d               enable debug logs [default:0]
#
# Changelog
# 2017-07-09
#   - Added ability to parse and apply default values in flag's description
# 2017-01-20
#   - script's output is copied in system clipboard
# 2016-12-21
#   - added helper case
#   - added support to boolean flags
# 2016-12-21 created

which xclip > /dev/null
do_xclip=$?

[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1
while getopts 'hs:d' OPT; do
    case $OPT in
        h)
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
        s)
            _script_path=$OPTARG
            ;;
        d)
            _d=1
            ;;
        \?)
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done

dlog(){
    [ ! -z $_d ] && echo $@
}

varsfile=$(mktemp /tmp/varsfile.XXX)
sed -n 's_^##\s*-\(.*\)_\1_p' $_script_path | sed -n 's|\(\w\)\s*<\(\w\+\)>|\1: _\2=$OPTARG|p' | cut -d ' ' -f1,2 > $varsfile
sed -n 's_^##\s*-\(.*\)_\1_p' $_script_path | sed -n '/\w\s*<\w\+>/! s|\(\w\)|\1 _\1=1|p' | cut -d ' ' -f1,2 >> $varsfile

flaglist=`cut -d ' ' -f1  $varsfile | tr -d '\n'`
variables=`cut -d ' ' -f2  $varsfile`

defaults=$(mktemp /tmp/defaults.XXX)
sed -n 's_^##\s*-\(.*\)_\1_p' $_script_path | sed -n 's|\(\w\)\s*<\(\w\+\)>\s*.*\[default:\s*\(.*\)\]|_\2=\3|p' > $defaults
sed -n 's_^##\s*-\(.*\)_\1_p' $_script_path | sed -n '/\w\s*<\w\+>/! s|\(\w\)\s*.*\[default:\s*\(.*\)\]|_\1=\2|p' >> $defaults

dlog content of varsfile
[ ! -z $_d ] && cat $varsfile && echo

dlog content of defaults
[ ! -z $_d ] && cat $defaults && echo

exec 5<&1
exec 1> ./tmpfile

if [ $(cat $defaults | wc -l) -gt 0 ]; then
    echo "# Default values"
    cat $defaults
fi

cat << EOF

# No-arguments is not allowed
[ \$# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' \$0 && exit 1

# Parsing flags and arguments
while getopts 'h${flaglist}' OPT; do
    case \$OPT in
        h)
            sed -ne 's/^## \(.*\)/\1/p' \$0
            exit 1
            ;;
EOF

IFS=$'\n'       # make newlines the only separator
for j in $(cat $varsfile)
do
    flag=$(echo $j | cut -c1)
    var=$(echo $j | cut -d' ' -f2)
    cat << EOF
        $flag)
            $var
            ;;
EOF
done


cat << EOF
        \?)
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' \$0
            exit 1
            ;;
    esac
done
EOF

# Show result in stdout
cat ./tmpfile >&5
# Copy result in system clipboard
cat ./tmpfile | xclip
cat ./tmpfile | xclip -sel clip
