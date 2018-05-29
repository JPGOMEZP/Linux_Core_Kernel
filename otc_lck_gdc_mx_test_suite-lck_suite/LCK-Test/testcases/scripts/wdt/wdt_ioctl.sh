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
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Ported from LTP-DDT project to LCK project.
#     - Modified script to align to the LCK standard.
#     - Added 'load_unload_module.sh' call.
# Mar, 2016
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Removed '--ioctl' parameter and added logic in order to get WDT
#       device node dinamically.

############################ DESCRIPTION ######################################

# This script handle ioctl to get information about Watchdog Timer.

############################# FUNCTIONS #######################################

usage()
{
	cat<<_EOF
	Usage:./${0##*/} [--device DEV_NODE] [--ioctl IOCTL_CMD] [--ioctlarg IOCTL_ARGUMENT] [--loop TEST_LOOP]
	Option:
		--device: device node under /dev
		--ioctl: ioctl command to operate WDT
		--ioctlarg: some ioctl command may need argument
		--loop: loops need to be tested
		--help: look for usage
_EOF
}

verified_params()
{
	local ref=""
	if [ $# -ne 2 ];then
		test_print_trc "please input parameter"
		return 1
	fi
	if [ -z "$1" ] || [ -z "$2" ];then
		test_print_trc "please input "$1""
		return 1
	else
		ref=$(echo $2 | cut -c 1-2)
		if [ $ref = "--" ] || [ $ref = "-" ];then
			test_print_trc "illegal parameters,please try again"
			return 1
		fi
	fi
	return 0
}

############################ DO THE WORK ######################################

source "common.sh"

IOCTL_FLAG="0"
DEV_FLAG="0"
while [ "$1" != "" ]
do
	case $1 in
		--ioctl)
			IOCTL_FLAG="1"
			shift
			verified_params "ioctl" "$1"
			if [ $? -ne 0 ];then
				exit 1
			fi
			IOCTL_CMD=$1
		;;
		--ioctlarg)
			shift
			verified_params "ioctl argument" "$1"
			if [ $? -ne 0 ];then
				exit 1
			fi
			IOCTL_ARG=$1
		;;
		--loop)
			shift
			verified_params "test loop" "$1"
			if [ $? -ne 0 ];then
				exit 1
			fi
			TEST_LOOP=$1
		;;
		--help)
			usage
			exit 0
		;;
	esac
	shift
done

# WDT SYSFS
WDT_DEV="/sys/class/watchdog"

# LOAD DRIVER
do_cmd load_unload_module.sh -l -d wdat_wdt

# GET WDT DEVICE NODE
DEV=`ls $WDT_DEV | grep "watchdog1"`
if [ ! -z $DEV ]; then
  DEV_NODE="/dev/${DEV}"
else
  DEV_NODE="/dev/watchdog0"
fi

# HANDLE IOCTLs
case $IOCTL_CMD in
	getsupport)
	do_cmd "wdt_tests -device $DEV_NODE -ioctl getsupport"
	;;
	settimeout)
	if [ -z $IOCTL_ARG ];then
		IOCTL_ARG="20"
	fi
	do_cmd "wdt_tests -device $DEV_NODE -ioctl settimeout -ioctlarg $IOCTL_ARG"
	;;
	gettimeout)
        do_cmd "wdt_tests -device $DEV_NODE -ioctl settimeout -ioctlarg $IOCTL_ARG"
	do_cmd "wdt_tests -device $DEV_NODE -ioctl gettimeout"
	;;
	getstatus)
	do_cmd "wdt_tests -device $DEV_NODE -ioctl getstatus"
	;;
	getbootstatus)
	do_cmd "wdt_tests -device $DEV_NODE -ioctl getbootstatus"
	;;
	keepalive)
	if [ -z $TEST_LOOP ];then
		TEST_LOOP="120"
	fi
	do_cmd "wdt_tests -device $DEV_NODE -ioctl keepalive -loop $TEST_LOOP"
	;;
	write)
	if [ -z $TEST_LOOP ] || [ $TEST_LOOP -eq 0 ];then
		do_cmd "wdt_tests -device $DEV_NODE -ioctl -write"
	else
		do_cmd "wdt_tests -device $DEV_NODE -ioctl -write -loop $TEST_LOOP"
	fi
	;;
esac

# UNLOAD DRIVER
#do_cmd load_unload_module.sh -u -d wdat_wdt
