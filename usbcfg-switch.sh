#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## options
##      -p, --pid <pid>

# CLInt GENERATED_CODE: start

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--pid") set -- "$@" "-p";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hv:p:' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        p) _pid=$OPTARG ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end

check_pid_exists(){
    if ! lsusb | grep $_pid 2>/dev/null; then
        echo [!] no device with PID $_pid seems connected
        exit 1
    fi
}

show_available_usbconfigs(){
    local modem=$1
    local pid=$2
    if [[ $modem == "LE910Cx" ]]; then
        echo "$modem modes"
        echo [+] 0	0x1201	DIAG+ADB+RmNet+NMEA+MODEM+MODEM+SAP
        echo [+] 1	0x1203	RNDIS+DIAG+ADB+NMEA+MODEM+MODEM+SAP
        echo [+] 2	0x1204	DIAG+ADB+MBIM+NMEA+MODEM+MODEM+SAP
        echo [+] 3	0x1205	MBIM
        echo [+] 4	0x1206	DIAG+ADB+ECM+NMEA+MODEM+MODEM+SAP
        echo [+] 5	0x1250	RmNet+NMEA+MODEM+MODEM+SAP
        echo [+] 6	0x1251	RNDIS+NMEA+MODEM+MODEM+SAP
        return 0
    fi
    if [[ $modem == "LM940" ]] || [[ $modem == "LM960" ]]; then
        echo "$modem modes"
        echo [+] 0	1042	RNDIS DIAG ADB NMEA MODEM MODEM AUX
        echo [+] 1	1040	DIAG ADB RMnet NMEA MODEM MODEM AUX
        echo [+] 2	1041	DIAG ADB MBIM MODEM MODEM AUX
        echo [+] 3	1043	DIAG ADB ECM NMEA MODEM MODEM AUX
        return 0
    fi
    if [[ $modem == "LN920" ]]; then
        echo "$modem modes"
        echo [+] 0	0x1062	RNDIS + DIAG + ADB + NMEA + MODEM + MODEM + AUX
        echo [+] 1	0x1060	DIAG + ADB + RmNet + NMEA + MODEM + MODEM + AUX
        echo [+] 2	0x1061	DIAG + ADB + MBIM + NMEA + MODEM + MODEM + AUX
        echo [+] 3	0x1063	DIAG + ADB + ECM + NMEA + MODEM + MODEM + AUX
        echo [+] 4	0x1064	MBIM
        return 0
    fi
    echo [!] unknown modem $modem
    exit 1
}

choose_mode() {
    echo [+] choose a new usbcfg mode from above list
    read mode
    echo $mode
}

check_pid_exists

[[ $_pid == "1040" ]] && modem="LM940" && tty=/dev/ttyUSB3
[[ $_pid == "1066" ]] && modem="LN920" && tty=/dev/ttyUSB3
[[ $_pid == "1250" ]] && modem="LE910Cx" && tty=/dev/ttyUSB3

set -u
show_available_usbconfigs $modem $_pid
choose_mode
echo [+] mode choosen $mode
set -x
sudo sendat -p $tty -c 'at#usbcfg='$mode

