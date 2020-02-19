#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vi: set ft=python :
import sys
from os import path
import re
import subprocess
import logging
import argparse
import ipaddress
from copy import deepcopy

USAGE = """
    pyqmi --path </path/to/cdc-wdm> [other options]
"""

logging.basicConfig(
    level=logging.INFO, format="[%(levelname)s %(funcName)s:%(lineno)s] %(message)s"
)
LOGGER = logging.getLogger(__name__)
INFO = LOGGER.info
ERR = LOGGER.error
WARN = LOGGER.warning
DBG = LOGGER.debug

DEVICE = None


def main():
    """Main function"""
    opts = options()
    global DEVICE
    DEVICE = opts.path
    if not connect(opts.iface, opts.apn, opts.type, opts.qmap):
        ERR("connect failed")


def configure(iface, apns, iptypes, qmap):
    """configure interface and return proper settings for start_network """

    connections = dict()
    if qmap:
        if not len(apns) == 2:
            raise Exception("You need two APNs for QMAP connection")

        rmnets = ["qmimux0", "qmimux1"]
        qmux_ids = [1, 2]

        if len(iptypes) == 1:
            INFO("using iptype %s for both connections", iptypes[0])
            iptypes = 2 * iptypes

        tables = ["tableA", "tableB"]
        for table in tables:
            if not routing_table_exists(table):
                ERR("table %s does not exists", table)
                INFO("Add table named %s to your /etc/iproute2/rt_table file", table)
                return False

        if not WDA_SET_DATA_FORMAT():
            raise Exception("could not set wda data format")

        for qmux_id, rmnet in zip(qmux_ids, rmnets):
            data = GET_IFACE(rmnet)
            if not data.get("iface", False):
                add_mux(qmux_id, iface)  # qmux is added to the main iface (e.g. wwan0)

    else:
        rmnets = len(iptypes) * [iface]
        qmux_ids = len(iptypes) * [0]
        tables = len(iptypes) * ["main"]

        # disable ip-raw to set MTU, then set it again
        run("ip link set {RMNET} down".format(RMNET=iface))
        if not SET_EXPECTED_DATA_FORMAT("802-3"):
            raise Exception("could not set ip raw type")
        run("ip link set {RMNET} mtu 16384".format(RMNET=iface))

        if not SET_EXPECTED_DATA_FORMAT("raw-ip"):
            raise Exception("could not set ip raw type")

    connections = zip(rmnets, apns, iptypes, qmux_ids, tables)
    return connections


def connect(iface, apns, iptypes, qmap=False):
    """Simple QMI connection"""

    # if "4" in iptypes and routing_gateway_exists():
    # ERR("Found a Gateway alredy defined. Please disable any connection first")
    # return False

    WDA_GET_DATA_FORMAT()
    if not NAS_GET_HOME_NETWORK():
        raise Exception("could not get Home network")

    connections = configure(iface, apns, iptypes, qmap)

    for rmnet, apn, iptype, qmux_id, table in connections:

        cid = WDS_GET_CLIENT_ID()["cid"]

        WDS_SET_IP_FAMILY(cid, iptype)
        WDS_GET_PROFILE_LIST(cid)

        if qmap:
            data = WDS_BIND_MUX_DATA_PORT(cid, qmux_id)

        WDS_START_NETWORK(cid, apn, iptype)

        data = WDS_GET_CURRENT_SETTINGS[iptype](cid)
        data["iface"] = rmnet
        data["table"] = table
        data["iptype"] = iptype

        if qmap:
            run("ip link set {RMNET} up".format(RMNET=iface))

        if not routing(data):
            ERR("routing error")
            return False

    return True


def routing_gateway_exists():
    """ Check if default gateway is already configured """
    data = parse(
        run("ip route", show=False), negative=True, default=".*default via (.*)"
    )
    return data is not None and len(data) > 0


def routing_table_exists(table):
    """ Check if the routing table exists """
    data = parse(
        run("cat /etc/iproute2/rt_tables", show=False),
        match=".*{TABLE_NAME}.*".format(TABLE_NAME=table),
    )
    return data is not None


def add_mux(qmux_id, iface):
    """ Create qmi qmux interface with the given id """
    return run(
        "echo {ID} | tee /sys/class/net/{IFACE}/qmi/add_mux".format(
            ID=qmux_id, IFACE=iface
        ),
        show=False,
    )


def bind_mux_port(qmux_id, cid):
    """ Bind mux data port """
    run(
        qmi_cmd(
            cid,
            "--verbose",
            "--wds-bind-mux-data-port=mux-id={QMUX_ID},ep-iface-number=2".format(
                QMUX_ID=qmux_id
            ),
            "--client-no-release-cid",
        )
    )


def routing(data):
    """ Configure routing table """

    address = data.get("addr", None)
    iface = data.get("iface", None)
    netmask = data.get("subnet", None)
    gateway = data.get("gw_addr", None)
    table = data.get("table", None)
    iptype = data.get("iptype", None)

    run("ip link set {RMNET} up".format(RMNET=iface))
    if iptype == "4":
        run(
            "ip addr add {IP}/{MASK} dev {RMNET}".format(
                IP=address, MASK=get_cdr(netmask), RMNET=iface
            )
        )
    else:
        run("ip -6 addr add {IP} dev {RMNET}".format(IP=address, RMNET=iface))

    if table == "main":
        run(
            "ip route add 8.8.8.8 via {GW} dev {RMNET} proto static".format(
                GW=gateway, RMNET=iface
            )
        )
    else:
        data = parse(
            run("ip route", show=False), net="(.*) dev {RMNET} .*".format(RMNET=iface)
        )
        run(
            "ip route add {NET} dev {RMNET} src {ADDR} table {TABLE}".format(
                NET=data["net"], RMNET=iface, ADDR=address, TABLE=table
            )
        )
        if gateway:
            run(
                "ip route add default via {GW} dev {RMNET} table {TABLE} proto static".format(
                    GW=gateway, RMNET=iface, TABLE=table
                )
            )
        run("ip rule add from {NET} table {TABLE}".format(NET=data["net"], TABLE=table))
        run("ip rule add to {NET} table {TABLE}".format(NET=data["net"], TABLE=table))

    return True


GET_IFACE = lambda name: parse(
    run("ip addr show", show=False),
    iface=r"\d+: {NAME}: .*".format(NAME=name),
    negative=True,
)

SET_EXPECTED_DATA_FORMAT = lambda format: parse(
    run(qmi_cmd(None, "--set-expected-data-format={}".format(format)))
)

WDA_GET_DATA_FORMAT = lambda: parse(run(qmi_cmd(None, "--wda-get-data-format")))
WDA_SET_DATA_FORMAT = lambda: parse(
    run(
        qmi_cmd(
            None,
            "--wda-set-data-format=link-layer-protocol=raw-ip,ul-protocol=qmap,dl-protocol=qmap,dl-datagram-max-size=16384",
        )
    )
)

WDS_BIND_MUX_DATA_PORT = lambda cid, qmux_id: parse(
    run(
        qmi_cmd(
            cid,
            "--wds-bind-mux-data-port=mux-id={QMUX_ID},ep-iface-number=2".format(
                QMUX_ID=qmux_id
            ),
            "--client-no-release-cid",
        )
    ),
    cid=r".*CID: '(\d+)'",
)

WDS_GET_CLIENT_ID = lambda: parse(
    run(qmi_cmd(None, "--wds-noop", "--client-no-release-cid")), cid=r".*CID: '(\d+)'"
)

WDS_GET_CURRENT_SETTINGS_IPV4 = lambda cid: parse(
    run(qmi_cmd(cid, "--wds-get-current-settings", "--client-no-release-cid")),
    cid=r".*CID: '(\d+)'",
    addr=r".*IPv4 address: (.*)",
    subnet=r".*IPv4 subnet mask: (.*)",
    gw_addr=r".*IPv4 gateway address: (.*)",
    dns1=r".*IPv4 primary DNS: (.*)",
    dns2=r".*IPv4 secondary DNS: (.*)",
    mtu=r".*MTU: (.*)",
)

WDS_GET_CURRENT_SETTINGS_IPV6 = lambda cid: parse(
    run(qmi_cmd(cid, "--wds-get-current-settings", "--client-no-release-cid")),
    cid=r".*CID: '(\d+)'",
    addr=r".*IPv6 address: (.*)",
    gw_addr=r".*IPv6 gateway address: (.*)",
    dns1=r".*IPv6 primary DNS: (.*)",
    dns2=r".*IPv6 secondary DNS: (.*)",
    mtu=r".*MTU: (.*)",
)
WDS_GET_CURRENT_SETTINGS = {
    "4": WDS_GET_CURRENT_SETTINGS_IPV4,
    "6": WDS_GET_CURRENT_SETTINGS_IPV6,
}

WDS_GET_PROFILE_LIST = lambda cid: parse(
    run(qmi_cmd(cid, "--wds-get-profile-list=3gpp", "--client-no-release-cid")),
    cid=r".*CID: '(\d+)'",
)

WDS_CREATE_PROFILE = lambda cid, apn: parse(
    run(
        qmi_cmd(
            cid,
            "--wds-create-profile=3gpp,apn={APN},pdp-type=IPV4".format(
                APN=apn),
            "--client-no-release-cid",
        )
    ),
    cid=r".*CID: '(\d+)'",
)

WDS_SET_IP_FAMILY = lambda cid, iptype: parse(
    run(
        qmi_cmd(cid, "--wds-set-ip-family={}".format(iptype), "--client-no-release-cid")
    ),
    cid=r".*CID: '(\d+)'",
)

WDS_START_NETWORK = lambda cid, apn, iptype: parse(
    run(
        qmi_cmd(
            cid,
            "--wds-start-network=apn={APN},ip-type={IPTYPE}".format(
                APN=apn, IPTYPE=iptype
            ),
            "--client-no-release-cid",
        )
    ),
    handle=r".*Packet data handle: '(.*)'",
    cid=r".*CID: '(\d+)'",
)
NAS_GET_HOME_NETWORK = lambda: parse(
    run(qmi_cmd(None, "--nas-get-home-network")),
    mcc=r".*MCC: '(.*)'",
    mnc=r".*MNC: '(.*)'",
)


def qmi_cmd(cid, *args):
    """Format a QMI command string"""
    command = "qmicli --device-open-proxy --device {}".format(DEVICE)

    for arg in args:
        command += " " + str(arg)

    if cid:
        command += " --client-cid={} ".format(cid)

    return command


def run(cmd, cwd=None, show=True):
    """Run the list of commands in a subprocess"""
    if not cwd:
        cwd = path.curdir

    if show:
        INFO(cmd)

    pipe = subprocess.Popen(cmd, cwd=cwd, shell=True, stdout=subprocess.PIPE)
    while pipe.wait() != 0:
        ERR("returncode %d from command: %s", pipe.returncode, cmd)
        sys.exit(1)

    if pipe.returncode != 0:
        raise Exception("%s returned non-zero code: %d" % (cmd, pipe.returncode))

    out = pipe.stdout.read().decode("utf-8")

    if show and len(out) > 0:
        INFO(out)

    return out


def parse(output, negative=False, **kwargs):
    """ Parse a multiline output string using the regex patterns in kwargs """

    if not output:
        return None

    if not kwargs:
        return output

    copy = deepcopy(kwargs)
    output = str(output).replace("\\t", "\t").replace("\\n", "\n")

    matches = dict()
    for line in output.split("\n"):
        if len(copy) == 0:
            break
        for key, pattern in kwargs.items():
            # DBG("looking for '{PATTERN}' in '{LINE}'".format(PATTERN=pattern, LINE=line))
            match = re.match(pattern, line)
            if not match:
                continue
            # group 1 is the whole line that matches, groups >=2 are the actual groups extracted
            if len(match.groups()) == 0:
                matches[key] = True
            elif len(match.groups()) == 1:
                matches[key] = match.group(1)
            else:
                ERR(
                    "found more than 1 match for '{}':'{}' -> '{}' (output was: {})".format(
                        key, pattern, match.groups(), line
                    )
                )
                return None

            del copy[key]
            break

    if not negative and len(copy) != 0:
        msg = "the following data has not been found: {}".format(copy)
        ERR(msg)
        sys.exit(1)

    return matches


def get_cdr(subnetmask):
    """ Return subnet mask prefix """
    addr = u"0.0.0.0/{}".format(subnetmask)
    prefix = ipaddress.IPv4Network(addr, strict=False).prefixlen
    return prefix


def options():
    """ Define CLI arguments """
    parser = argparse.ArgumentParser(usage=USAGE)
    parser.add_argument(
        "-p",
        "--path",
        required=True,
        help="path to cdc-wdm device (e.g. /dev/cdc-wdm1)",
    )
    parser.add_argument(
        "-i", "--iface", required=True, help="interface name (e.g. wwan0)"
    )
    parser.add_argument(
        "-t", "--type", default=["4"], nargs="+", help="IP type, either 4 or 6"
    )
    parser.add_argument("-a", "--apn", required=True, nargs="+", help="the SIM APN")
    parser.add_argument("-d", "--debug", action="store_true", help="show debug logs")
    parser.add_argument("--qmap", action="store_true", help="configure qmap")

    opts = parser.parse_args(args=None if sys.argv[1:] else ["--help"])
    if opts.debug:
        LOGGER.setLevel(logging.DEBUG)

    DBG(opts)

    return opts


if __name__ == "__main__":
    main()
