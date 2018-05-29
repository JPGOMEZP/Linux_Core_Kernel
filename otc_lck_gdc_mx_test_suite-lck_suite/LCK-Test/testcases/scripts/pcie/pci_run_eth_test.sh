#!/bin/bash

###############################################################################
#
# Copyright (C) 2011 Texas Instruments Incorporated - http://www.ti.com/
# Copyright (C) 2015 Intel - http://www.intel.com/
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation version 2.
#
# This program is distributed "as is" WITHOUT ANY WARRANTY of any
# kind, whether express or implied; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
###############################################################################

############################ CONTRIBUTORS #####################################

# Author: LTP-DDT
#
# Jan, 2016.
#   Juan Pablo Gomez (juan.p.gomez@intel.com)
#     - Ported from LTP-DDT projecto to LCK project.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Modified script in order to align it to LCK repository standard.
#     - Add '--force' to 'ifdown' and 'ifup' commands to ensure execution.

############################ DESCRIPTION ######################################

# This script runs PCI Ethernet tests.

############################# FUNCTIONS #######################################

usage() {
  cat <<-EOF >&2
    usage: ./${0##*/} [-i ETH_IFACE] [-a ACTION]
    -a ACTION the ethernet test to be run .
    -h Help   print this usage
EOF

  exit 0
}

############################ DO THE WORK ######################################

source "common.sh"

while getopts :i:a:h arg
do case $arg in
  i)  ETH_IFACE="$OPTARG";;
  a)  ACTION="$OPTARG";;
  h)  usage;;
  :)  test_print_trc "$0: Must supply an argument to -$OPTARG." >&2
      exit 1
      ;;
  \?) test_print_trc "Invalid Option -$OPTARG ignored." >&2
      usage
      exit 1
      ;;
esac
done

if [ -z "${ETH_IFACE}" ]; then
  ETH_IFACE=`pci_eth_search_device.sh` || die "error getting pcie eth interface name";
  test_print_trc "PCI eth iface: $ETH_IFACE"
fi

test_print_trc "ACTION: $ACTION"
test_print_trc "ETH_IFACE: $ETH_IFACE"

# PREPARE PCI ETH TEST
IFACE_LIST=`pci_get_active_eth_interfaces.sh`
test_print_trc "Active Ethernet Ports: ${IFACE_LIST[@]}"

IFACE_CONFIG="iface ${ETH_IFACE} inet dhcp";

grep "$IFACE_CONFIG" /etc/network/interfaces || ( echo "#$IFACE_CONFIG" >> /etc/network/interfaces );

for interface in ${IFACE_LIST[@]}; do
  do_cmd "ifdown --force $interface"
  sleep 10
done;

do_cmd "ifup --force ${ETH_IFACE}";

HOST=`pci_get_eth_gateway.sh -i $IFACE_LIST` || die "error getting eth gateway address";
test_print_trc "host:${HOST}"

# RUN ETH TESTS
if [ -n "$ACTION" ]; then
  eval "$ACTION"
fi

# CLEAN UP AFTER PCI ETH TEST
do_cmd "ifdown --force $ETH_IFACE"
sleep 10

for interface in ${IFACE_LIST[@]}; do
  do_cmd "ifup --force $interface";
done

exit 0
#do_cmd "service network-manager restart"
