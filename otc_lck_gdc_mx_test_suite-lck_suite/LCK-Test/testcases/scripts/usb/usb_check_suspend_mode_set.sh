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

# @desc This script verify check suspend mode on  controllers
# @params None
# @returns Fail the test if return code is non-zero (value set not found)

############################# FUNCTIONS #######################################

usage()
{
	cat <<-EOF >&2
	usage: ./${0##*/}
	EOF
	exit 0
}

############################ DO THE WORK ######################################

source "common.sh"

while getopts  :h: arg
do case $arg in
		h)      usage;;
		:)      die "$0: Must supply an argument to -$OPTARG.";;
		\?)     "Invalid Option -$OPTARG ";;
esac
done

REGEX='usb'

for CONTROLLER in $(ls $USB_PATH |grep $REGEX)
do
    test_print_trc "Controller: $CONTROLLER"
    echo on > $USB_PATH/$CONTROLLER/power/control
    cat $USB_PATH/$CONTROLLER/power/runtime_enabled |grep forbidden
    echo auto > $USB_PATH/$CONTROLLER/power/control;
    cat $USB_PATH/$CONTROLLER/power/runtime_enabled | grep enabled
    if [ $? -ne 0 ];then
        die "D3hot was not able to be set"
    fi

done
exit $?
