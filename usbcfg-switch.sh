#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## options
##      -p, --pid <pid>         Currently connected device PID to reconfigure
##      -t, --timeout <seconds> Timeout for checking reconnection automatically [default:30]

# CLInt GENERATED_CODE: start
# info: https://github.com/clobrano/CLInt.git
# Default values
_timeout=30

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--pid") set -- "$@" "-p";;
"--timeout") set -- "$@" "-t";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hp:t:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        p) _pid=$OPTARG ;;
        t) _timeout=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end


NEED_RESET=0

# --- MODES START ---
LE910Cx_modes=$(cat << EOF
0	1201	DIAG+ADB+RmNet+NMEA+MODEM+MODEM+SAP
1	1203	RNDIS+DIAG+ADB+NMEA+MODEM+MODEM+SAP
2	1204	DIAG+ADB+MBIM+NMEA+MODEM+MODEM+SAP
3	1205	MBIM
4	1206	DIAG+ADB+ECM+NMEA+MODEM+MODEM+SAP
5	1250	RmNet+NMEA+MODEM+MODEM+SAP
6	1251	RNDIS+NMEA+MODEM+MODEM+SAP
EOF
)
LE910_V2_modes=$(cat << EOF
0  0036   NCM
1  0034   
2  0035   
3  0032   MBIM+NCM
4  0037   NCM
5  0033   MBIM+NCM
EOF
)
LM9x0_modes=$(cat << EOF
0	1042	RNDIS DIAG ADB NMEA MODEM MODEM AUX
1	1040	DIAG ADB RMnet NMEA MODEM MODEM AUX
2	1041	DIAG ADB MBIM MODEM MODEM AUX
3	1043	DIAG ADB ECM NMEA MODEM MODEM AUX
EOF
)
LN920_modes=$(cat << EOF
0	1062	RNDIS + DIAG + ADB + NMEA + MODEM + MODEM + AUX
1	1060	DIAG + ADB + RmNet + NMEA + MODEM + MODEM + AUX
2	1061	DIAG + ADB + MBIM + NMEA + MODEM + MODEM + AUX
3	1063	DIAG + ADB + ECM + NMEA + MODEM + MODEM + AUX
4	1064	MBIM
EOF
)
# --- MODES END ---

# --- FUNCTIONS START ---
check_dependencies() {
    dependencies=(sendat expect)
    for dependency in ${dependencies[@]}; do
        if ! which $dependency 1>/dev/null; then
            echo [!] "$dependency" binary not found. Please install it
            exit -1
        fi
    done
}
check_pid_exists(){
    if ! lsusb | grep $_pid 2>/dev/null; then
        echo [!] no device with PID $_pid seems connected
        exit 1
    fi
}

choose_mode() {
    echo [+] choose a new usbcfg mode from above list
    read mode
    echo $mode
}
# --- FUNCTIONS END ---

# --- MAIN ---
set -e
check_dependencies
check_pid_exists
case ${_pid} in

    0036|0034|0035|0032|0037|0033)
        modem="LE910_V2"
        tty=/dev/ttyACM0
        NEED_RESET=1
        ;;
    1040|1042|1041|1043)
        modem="LM9x0"
        tty=/dev/ttyUSB3
        ;;
    1201|1203|1204|1205|1206|1251)
        modem="LE910Cx"
        tty=/dev/ttyUSB3
        ;;
    1250)
        modem="LE910Cx"
        tty=/dev/ttyUSB1
        ;;
    1062|1060|1061|1063|1064|1066)
        modem="LN920"
        tty=/dev/ttyUSB3
        ;;
    *)
        echo [!] unrecognized PID $_pid
        exit 1
esac

set -u
modes=${modem}_modes
echo "Available modes for $modem:"
echo "${!modes}"
choose_mode

# getting what the next pid will be
next_pid=0
found=0
for text in ${!modes}; do
    if [[ $found == 0 ]]; then 
        if [[ $text == $mode ]]; then
            found=1
        fi
    else
        next_pid=$text
        break
    fi
done

if [[ $next_pid == 0 ]]; then
    echo [!] mode: $mode seems not available
    exit 1
fi

# send AT#USBCFG=<mode>
set -x
sudo sendat -p $tty -c 'at#usbcfg='$mode
set +x

if [[ $NEED_RESET == 1 ]]; then
    sudo sendat -p $tty -c 'at#reboot'
fi

dmesg_minor_version=$(dmesg --version | cut -d" " -f4 | cut -d"." -f2)

# dmesg --follow-new flag is supported from minor version 37 only
if [[ $dmesg_minor_version -ge 37 ]]; then
    echo [+] waiting $_timeout seconds for the modem to reconfigure into $next_pid...
/usr/bin/expect <<EOF
set timeout $_timeout
spawn dmesg --ctime --follow-new
expect {
    timeout { send_user "\nWait timed out. Either the modem is slower or did not reconfigure correctly, please check manually.\n"; exit 1 }
    eof { send_user "\ncould not get dmesg\n"; exit 1 }
    "New USB device found*idProduct=$next_pid*" { send_user "\nModem reconfigured correctly\n"; exit 0 }
}
EOF
fi
