#!/bin/bash

###############################################################################
#
# Copyright (C) 2016 Intel - http://www.intel.com/
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

# Author: sylvainx.heude@intel.com
#
# Jan, 2016. Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#   - Ported from 'otc_kernel_qa-tp_tc_scripts_linux_core_kernel' project to
#     LCK project.
#   - Modified script in order to align it to LCK repository standard.
# May, 2016
#   - Updated script to give more accurate information to the user
#   - Improved script in order to execute a more accurate test and show more
#     information about what it is doing.
#   - Added a loop option in order to perform stress test.


############################ DESCRIPTION ######################################

# This script set a new time and check if it was set correctly.

############################ FUNCTIONS ########################################

usage()
{
cat <<-EOF >&2
  usage: ./${0##*/} [-l LOOP]
    -l LOOP	Test loop
EOF
exit 0
}

############################ DO THE WORK ######################################

source "common.sh"

while getopts :l:h arg
do case $arg in
    l) LOOP="$OPTARG" ;;
    h) usage ;;
    :) test_print_trc "$0: Must supply an argument to -$OPTARG." >&2
       exit 1 ;;
    \?) test_print_trc "Invalid Option -$OPTARG ignored." >&2
	usage
        exit 1 ;;
  esac
done

# DEFAULT VALUES IF NOT SET IN 'getopts'
: ${LOOP:='1'}

CUR_TIME=$(date +%H:%M:%S)
TEST_TIME="11:34:00"
x=0

while [ $x -lt $LOOP ]
do
  test_print_trc "============ LOOP: $x ============"
  # SET NEW TIME
  test_print_trc "Current time is: $CUR_TIME"
  test_print_trc "Set new time to: $TEST_TIME"
  sleep 2

  do_cmd "date +%H%M%S -s ${TEST_TIME}"
  if [ $? -eq 0 ]; then
    test_print_trc "Time was successfully set to ${TEST_TIME}"
  else
    die "Can't set a new time"
  fi

  # CHECK IF NEW TIME WAS SET CORRECTLY
  NEW_TIME=$(date +%H%M)
  if [ $(($(date +%H%M)-$NEW_TIME)) -ne 0 ]; then
    die "Time set is wrong"
  fi

  sleep 2

  # SET CURRENT TIME
  test_print_trc "Set time to current time $CUR_TIME"
  do_cmd "date +%H%M%S -s ${CUR_TIME}"
  if [ $? -eq 0 ]; then
    test_print_trc "Time was successfully set to current time ${CUR_TIME}"
  else
    die "Can't set current time"
  fi

  x=$((x+1))
done
