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

# Author: Rogelio Ceja <rogelio.ceja@intel.com>
#
# History:
#   May. 18, 2015 - (rogelio.ceja)Creation
# May, 2016. Juan Carlos Alonso <juan.carlos.alonso@intelcom>
#   Aling it to the LCK standar

############################# DESCRIPTION #####################################

# This script checks that USB  modules are correct loaded in /sys/module/
# @params None
# @returns Fail the test if return code is non-zero (value set not found)

############################# FUNCTIONS #######################################

usage()
{
	cat <<-EOF >&2
	usage: ./${0##*/} [-m MODULE]
        -m MODULE	Module you want to verify is present.
	EOF
	exit 0
}

############################ DO THE WORK ######################################

source "common.sh"

while getopts m:h: arg
do case $arg in
	m)  MODULE="$OPTARG";;
	h)  usage;;
	:)  die "$0: Must supply an argument to -$OPTARG.";;
	\?) die "Invalid Option -$OPTARG ";;
  esac
done

# DEFAULT VALUES IF NOT SET IN 'getopts'
: ${MODULE:='xhci_hcd'}

test_print_trc "Check driver loaded in $MODULE_PATH"
do_cmd "ls $MODULE_PATH | grep $MODULE"
if [ $? -ne 0 ];then
  test_print_trc "USB module $MODULE is not in $MODULE_PATH. It is not loaded"
else
  test_print_trc "ls $MODULE_PATH/$MODULE | grep drivers"
  ls $MODULE_PATH/$MODULE | grep drivers
  if [ $? -eq 0 ]; then
    test_print_trc "Drivers related are:"
    do_cmd "ls -l $MODULE_PATH/$MODULE/drivers"
  else
    test_print_trc "There is not drivers related"
  fi
fi
