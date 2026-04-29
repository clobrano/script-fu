#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## when-done waits for a process to end, then notifies the user.
## You can choose which process to wait for by passing a query as an argument.
## If no query is passed, you will be prompted to select a process.
## If multiple processes match the query, you will be prompted to select one.
## The notification is done by printing a message to the terminal, or by sending a message to ntfy.
## options:
##   -q, --query <query>  query to select the process to wait for
##   -l, --local          send a local notification when the process ends (via notify-send)
##   -r, --remote         send a remote notification when the process ends (via ntfy)

# CLInt GENERATED_CODE: start
# info: https://github.com/clobrano/CLInt.git

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--query") set -- "$@" "-q";;
"--local") set -- "$@" "-l";;
"--remote") set -- "$@" "-r";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hlrq:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        l) _local=1 ;;
        r) _remote=1 ;;
        q) _query=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end

res=$(pgrep -a "${_query:-.}" | grep -v " $0" | fzf \
    --header $'Press ENTER to select the process' \
    --layout=reverse --info=inline --no-multi \
    --prompt 'Search >' --preview-window hidden:wrap)

if [[ -z "$res" ]]; then
    echo "No process selected"
    exit 1
fi

pid=$(echo "$res" | awk '{print $1}')
cmd=$(echo "$res" | cut -d' ' -f2-)

PIDFILE=/tmp/when-done-$(date +%Y%m%d-%H%M%S).yaml

sendNotification() {
    if [[ $_local -eq 1 ]]; then
        notify-send -u critical -i "info" "[when-done] finished" "Process $pid: $cmd"
        if [ -f /usr/share/sounds/freedesktop/stereo/complete.oga ]; then
            paplay /usr/share/sounds/freedesktop/stereo/complete.oga
        fi
    fi
    if [[ $_remote -eq 1 ]]; then
        if [ -n "$NTFY_HANDLE" ]; then
            ./ntfy-send.sh -c "$NTFY_HANDLE" -m "[when-done] finished: $cmd (PID $pid)"
        fi
    fi
}

(
    tail --pid=${pid} --follow /dev/null
    sendNotification
    [[ -f "$PIDFILE" ]] && rm "$PIDFILE"
) &

TAIL_PID=$!
cat << EOF > "$PIDFILE"
cmd: $cmd
pid: $TAIL_PID
target_pid: $pid
EOF

echo -e "Let's wait for ${pid}: \e[4m${cmd}\e[0m to end (PIDFILE=$PIDFILE)"

