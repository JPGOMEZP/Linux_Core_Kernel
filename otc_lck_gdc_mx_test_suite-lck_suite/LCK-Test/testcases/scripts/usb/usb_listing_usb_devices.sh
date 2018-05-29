#!/bin/bash

################################################################################
#
# Copyright 2015 Intel Corporation
#
# This file is part of LTP-DDT for IA to validate USB component
#
# This program file is free software; you can redistribute it and/or modify it
# under the terms and conditions of the GNU General Public License,
# version 2, as published by the Free Software Foundation.
#
# This program is distributed in the hope it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
################################################################################

############################ CONTRIBUTORS ######################################
#
# Author:
#             Rogelio Ceja <rogelio.ceja@intel.com>
#
# History:
#             May. 18, 2015 - (rogelio.ceja)Creation

############################# DESCRIPTION #####################################

# @desc This script checks that USB devices are reported correctly
# @params None
# @returns Fail the test if return code is non-zero (value set not found)

############################# FUNCTIONS #######################################

usage()
{
	cat <<-EOF >&2
	usage: ./${0##*/}
        -n NO_PARMS 	No parameters required.
	EOF
	exit 0
}

############################ DO THE WORK ######################################

source "common.sh"

while getopts  h: arg
do case $arg in
		h)	usage;;
		:)	die "$0: Must supply an argument to -$OPTARG.";;
		\?)	die "Invalid Option -$OPTARG ";;
esac
done

# DEFAULT VALUES IF NOT SET IN 'getopts'
: ${MODULE:='uhci_hcd'}

DEV_FILE="usbdev.txt"
DEV_OUT="usbdev.out"
LSUSB_FILE="lsusb.txt"
LSUSB_OUT="lsusb.out"

cat $DEVICE_PATH | grep P: | awk -F "=" '{print $2 " " $3}' | awk '{print $1 ":" $3}' > $DEV_FILE
sort -b $DEV_FILE>$DEV_OUT
cat $DEV_OUT
lsusb | awk '{print $6}'>$LSUSB_FILE
sort -b $LSUSB_FILE > $LSUSB_OUT
cat $LSUSB_OUT

# THIS STEP COMPATES THOSE 2 FILES AND PUT THE RESULT IN A VARIABLE
compare=`cmp $DEV_OUT $LSUSB_OUT`

if [ -z $compare ]; then
    test_print_trc "PASS"
else
    test_print_trc "FAIL: they is a difference between lsusb and sysfs"
    exit 1
fi

# LETS CLEAN WORK ENVIRONMENT
rm $LSUSB_FILE; rm $DEV_FILE; rm $LSUSB_OUT; rm $DEV_OUT
exit $?
