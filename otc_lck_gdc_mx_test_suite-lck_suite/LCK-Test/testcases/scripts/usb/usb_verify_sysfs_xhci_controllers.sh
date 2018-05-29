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

# @desc This script verify controllers files exist on sysfs
# @params None
# @returns Fail the test if return code is non-zero (value set not found)

############################# FUNCTIONS #######################################

usage()
{
	cat <<-EOF >&2
	usage: ./${0##*/} [-t TYPE]
	EOF
	exit 0
}

############################ DO THE WORK ######################################

source "common.sh"

while getopts  :h: arg
do case $arg in
  	h)  usage;;
	:)  die "$0: Must supply an argument to -$OPTARG.";;
	\?) "Invalid Option -$OPTARG ";;
  esac
done

REGEX='usb'
FILES=("async" "runtime_active_kids" "runtime_enabled" "runtime_status" "runtime_usage")

for CONTROLLER in $(ls $USB_PATH |grep $REGEX)
do
    test_print_trc "Files For Controller: $CONTROLLER"
    for ENTRY_FILE in "${FILES[@]}"
    do
        do_cmd ls $USB_PATH/$CONTROLLER/power |grep "$ENTRY_FILE"
        if [ $? -ne 0 ];then
            test_print_trc "$ENTRY_FILE was not found on
            $USB_PATH/$CONTROLLER/power"
            exit 1
        fi
        test_print_trc "Entry File Found: $ENTRY_FILE"
    done
done
