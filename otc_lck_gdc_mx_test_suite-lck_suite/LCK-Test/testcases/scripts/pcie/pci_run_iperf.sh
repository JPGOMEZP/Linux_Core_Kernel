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

############################ DESCRIPTION ######################################

# This script runs IPERF Tool.
# Can get such tool from: http://sourceforge.net/projects/iperf/

############################# FUNCTIONS #######################################

usage() {
  echo "run_iperf.sh -H <host> [other iperf options (see iperf help)"
  echo " -H <host>: IP address of Host running iperf in server mode"
  echo " all other args are passed as-is to iperf"
  echo " iperf help:"
  echo `iperf -h`
exit 1
}

############################ DO THE WORK ######################################

source "common.sh"

while getopts  :H:h arg
do case $arg in
        H)      IPERFHOST="$OPTARG"; shift 2 ;;
        h)      usage;;
        :)      ;;
        \?)     ;;
esac
done

#: ${IPERFHOST:=`cat /proc/cmdline | awk '{for (i=1; i<=NF; i++) { print $i} }' | grep 'nfsroot=' | awk -F '[=:]' '{print $2}'`}
IPERFHOST=10.219.128.64

[ -n "$IPERFHOST" ] || die "IPERF server IP address could not be determined \
dynamically. Please specify it when calling the script. \
(i.e. run_iperf.sh -H <host>)"

#IPERFCMD=`echo $* | sed -r s/-H[[:space:]]+[0-9\.]+/-c $IPERFHOST/`

test_print_trc "Starting IPERF TEST: ${IPERFHOST}"

do_cmd "iperf -c ${IPERFHOST} $*"
