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
##   -L, --list           list all the processes currently being observed

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
"--list") set -- "$@" "-L";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hlrLq:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        l) _local=1 ;;
        r) _remote=1 ;;
        L) _list=1 ;;
        q) _query=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end

list_observed() {
    local files=(/tmp/when-done-*.yaml)
    if [[ ! -e "${files[0]}" ]]; then
        echo "No processes are currently being observed."
        return 0
    fi

    local header_printed=0

    for file in "${files[@]}"; do
        if [[ ! -f "$file" ]]; then continue; fi

        local p_pid=""
        local p_target_pid=""
        local p_cmd=""

        while IFS=': ' read -r key val; do
            case "$key" in
                pid) p_pid="$val" ;;
                target_pid) p_target_pid="$val" ;;
                cmd) p_cmd="$val" ;;
            esac
        done < "$file"

        if [[ -n "$p_pid" ]] && kill -0 "$p_pid" 2>/dev/null; then
            if [[ $header_printed -eq 0 ]]; then
                printf "%-10s %-15s %s\n" "OBSERVER" "TARGET_PID" "COMMAND"
                printf "%-10s %-15s %s\n" "--------" "----------" "-------"
                header_printed=1
            fi
            printf "%-10s %-15s %s\n" "$p_pid" "$p_target_pid" "$p_cmd"
        else
            # Observer is no longer running, clean up stale file
            rm -f "$file"
        fi
    done

    if [[ $header_printed -eq 0 ]]; then
        echo "No processes are currently being observed."
    fi
}

if [[ $_list -eq 1 ]]; then
    list_observed
    exit 0
fi

find_predecessor() {
    local inode
    inode=$(readlink /proc/self/fd/0 2>/dev/null)
    [[ $inode =~ pipe:\[([0-9]+)\] ]] || return 1
    local inode_num=${BASH_REMATCH[1]}

    if command -v lsof >/dev/null 2>&1; then
        # find who has this pipe open for writing (fd 1 or 2 usually)
        local p
        # -t: terse (PIDs only), -w: suppress warnings, -E: show endpoint info (can be useful but we use grep)
        p=$(lsof -t -d 1,2 -w 2>/dev/null | grep -v "^$$\$" | xargs -I {} sh -c "ls -l /proc/{}/fd 2>/dev/null | grep -q 'pipe:\[$inode_num\]' && echo {}" | head -n 1)
        if [[ -n $p ]]; then
            echo "$p"
            return 0
        fi
    fi

    # Fallback to /proc scanning
    for fd_dir in /proc/[0-9]*/fd; do
        # Skip self
        [[ $fd_dir =~ /proc/$$/ ]] && continue

        # Extract PID from fd_dir
        local current_pid
        current_pid=$(echo "$fd_dir" | cut -d/ -f3)

        for fd in "$fd_dir"/*; do
            [[ -e "$fd" ]] || continue
            # We want to find who is WRITING to our pipe
            # In /proc/PID/fdinfo/FD there is a 'flags' field
            # O_WRONLY (1) or O_RDWR (2)
            if readlink "$fd" 2>/dev/null | grep -q "pipe:\[$inode_num\]"; then
                local fd_num
                fd_num=$(basename "$fd")
                if grep -qE "flags:[[:space:]]*[1-9][0-9]*[12]" "/proc/$current_pid/fdinfo/$fd_num" 2>/dev/null; then
                    echo "$current_pid"
                    return 0
                fi
            fi
        done
    done
    return 1
}

wait_and_get_status() {
    local target_pid=$1
    local exit_code="unknown"

    if command -v strace >/dev/null 2>&1; then
        # Attach strace to get the exit code
        local strace_out
        strace_out=$(strace -e trace=none -p "$target_pid" 2>&1)
        if [[ $strace_out =~ exited\ with\ ([0-9]+) ]]; then
            exit_code=${BASH_REMATCH[1]}
        elif [[ $strace_out =~ killed\ by\ ([A-Z0-9]+) ]]; then
            exit_code="SIG${BASH_REMATCH[1]}"
        fi
    elif [ -d "/proc/$target_pid" ]; then
        # Fallback to tail if strace is not available
        tail --pid="$target_pid" --follow /dev/null
    fi
    echo "$exit_code"
}

sendNotification() {
    local status=$1
    local msg_suffix=""
    local icon="info"
    local title="[when-done] finished"

    case "$status" in
        0)
            msg_suffix="SUCCESS ✅"
            icon="emblem-success"
            ;;
        unknown)
            msg_suffix="DONE 🏁"
            ;;
        SIGINT|SIGTERM|SIGKILL|SIG*)
            msg_suffix="KILLED 💀 ($status)"
            icon="error"
            ;;
        *)
            msg_suffix="FAILED ❌ (status: $status)"
            icon="error"
            ;;
    esac

    if [[ $_local -eq 1 ]]; then
        notify-send -u critical -i "$icon" "$title" "$msg_suffix\n${cmd:0:20}..."
        if [ -f /usr/share/sounds/freedesktop/stereo/complete.oga ]; then
            paplay /usr/share/sounds/freedesktop/stereo/complete.oga
        fi
    fi
    if [[ $_remote -eq 1 ]]; then
        if [ -n "$NTFY_HANDLE" ]; then
            ./ntfy-send.sh -c "$NTFY_HANDLE" -m "$title: $msg_suffix - ${cmd:0:20}..."
        fi
    fi
}

if [[ ! -t 0 ]]; then
    # We are receiving data via pipe
    pid=$(find_predecessor || echo "piped")

    if [[ $pid =~ ^[0-9]+$ ]]; then
        cmd=$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null || echo "piped process")
        # Start strace in background to capture the exit code
        # We use a temp file to capture the status
        STATUS_FILE=$(mktemp)
        (
            wait_and_get_status "$pid" > "$STATUS_FILE"
        ) &
        STRACE_BG_PID=$!
    else
        cmd="piped process"
    fi

    set -o pipefail
    cat
    cat_status=$?
    # PIPESTATUS[0] is the exit code of the predecessor
    pipe_status=${PIPESTATUS[0]}

    if [[ -n $STRACE_BG_PID ]]; then
        # Wait a bit for strace to finish if it hasn't already
        wait "$STRACE_BG_PID" 2>/dev/null
        status=$(cat "$STATUS_FILE")
        rm "$STATUS_FILE"
    fi

    # If strace failed or was unknown, but we have PIPESTATUS
    if [[ $status == "unknown" || -z $status ]]; then
        status=$pipe_status
    fi

    sendNotification "$status"
    exit 0
fi

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

(
    status=$(wait_and_get_status "${pid}")
    sendNotification "$status"
    [[ -f "$PIDFILE" ]] && rm "$PIDFILE"
) &

TAIL_PID=$!
cat << EOF > "$PIDFILE"
cmd: $cmd
pid: $TAIL_PID
target_pid: $pid
EOF

echo -e "Let's wait for ${pid}: \e[4m${cmd}\e[0m to end (PIDFILE=$PIDFILE)"

