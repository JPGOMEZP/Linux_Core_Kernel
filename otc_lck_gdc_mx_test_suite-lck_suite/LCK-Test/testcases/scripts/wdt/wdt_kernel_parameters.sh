#!/bin/bash

###############################################################################
#
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

############################# CONTRIBUTORS ####################################

# Author: Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#
# Jan, 2016. Juan Carlos Alonso (juan.carlos.alonso@intel.com)
#     - Initial draft.
#     - Modified script to align to LCK standard.
# Apr, 2016. Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Added logic to get the current device node dinamically.

############################# DESCRIPTION #####################################

# This script load watchdog driver with kernel parameters:
#   - hearbeat: set the watchdog timeout.
#   - nowayout: set as 0 the watchdog can be desactivated to avoid a system
#               reset.
#               set as 1 the watchdog cannot be desactivated, system will reset

############################# FUNCTIONS #######################################

usage()
{
  cat<<_EOF
  Usage:./${0##*/} [-b] [-n] [-h]
  Option:
    -b  Set a Timeout with Heartbeat watchdog kernel parameter
    -n  Set Nowayout watchdog kernel parameter
    -h  Look for usage
_EOF
}

############################ DO THE WORK ######################################

source "common.sh"

TIMEOUT=30

while getopts :b:n:h arg
do case $arg in
	b)	HEARTBEAT="$OPTARG";;
	n)	NOWAYOUT="$OPTARG";;
	h)	usage;;
esac
done

: ${HEARTBEAT:='30'}
: ${NOWAYOUT:='0'}

# GET WDT DEVICE NODE
DEV=`ls $WDT_DEV | grep "watchdog1"`
if [ ! -z $DEV ]; then
  DEV_NODE="/dev/${DEV}"
else
  DEV_NODE="/dev/watchdog0"
fi


# LOAD DRIVER WITH 'nowayout' AND 'hertbeat' PARAMETERS
do_cmd load_unload_module.sh -p -l -d wdat_wdt -b "$HEARTBEAT" -w "$NOWAYOUT"

do_cmd "wdt_tests -device $DEV_NODE -ioctl settimeout -ioctlarg "40""

# GET TIMEOUT
do_cmd "wdt_tests -device $DEV_NODE -ioctl gettimeout"

# EXECUTE WATCHDOG MAGIC CLOSE
do_cmd wdt_simple_test.sh -m -k

# WAIT FOR TIMEOUT WHEN 'nowayout = 0'
if [ $NOWAYOUT -eq 0 ]; then
  test_print_trc "NOWAYOUT = $NOWAYOUT | Wait for timeout: $TIMEOUT | SYSTEM MUST NOT REBOOT"
  while [ $TIMEOUT -gt 0 ]; do
    sleep 1
    TIMEOUT=$[$TIMEOUT - 1]
  done

# WAIT FOR TIMEOUT WHEN 'nowayout = 1'
elif [ $NOWAYOUT -eq 1 ]; then
  test_print_trc "NOWAYOUT = $NOWAYOUT | Wait for timeout: $TIMEOUT | SYSTEM MUST REBOOT"
  while [ $TIMEOUT -gt 0 ]; do
    test_print_trc "$TIMEOUT SECONDS TO REBOOT"
    sleep 1
    TIMEOUT=$[$TIMEOUT - 1]
  done
fi
