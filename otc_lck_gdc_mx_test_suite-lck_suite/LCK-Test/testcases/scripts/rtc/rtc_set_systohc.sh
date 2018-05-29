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

# Author: <sylvainx.heude@intel.com>
#
# May, 2016. Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#   - Ported from 'otc_kernel_qa-tp_tc_scripts_linux_core_kernel' project to
#     LCK project.
#   - Updated script to align it with LCK standard.
#   - Improved script in order to execute a more accurate test and show more
#     information about what it is doing.
#   - Added a loop option in order to perform stress test.

############################ DESCRIPTION ######################################

# This script sets hardware clock from system clock with 'hwclock --systohc'

############################ FUNCTIONS ########################################

usage()
{
cat <<-EOF >&2
  usage: ./${0##*/} [-l LOOP]
    -l LOOP     Test loop
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

NEW_TIME="05:26:00"
x=0

while [ $x -lt $LOOP ]
do
  # GET CURRENT TIME OF HARDWARE AND SYSTEM CLOCK
  test_print_trc "Get both current HW and SYS time"
  do_cmd "CUR_HW_CLOCK=$(hwclock | awk '{print $5}')"
  test_print_trc "Current HW time $CUR_HW_CLOCK"
  do_cmd "CUR_SYS_CLOCK=$(date +%H:%M:%S)"
  test_print_trc "Current SYS time $CUR_SYS_CLOCK"

  sleep 2

  # SET SYS CLOCK
  test_print_trc "Set a new time to SYS clock"
  do_cmd "date +%H%M%S -s $NEW_TIME"
  if [ $? -eq 0 ]; then
    test_print_trc "Time was successfully set"
  else
    die "Can't set time to SYS clock"
  fi

  sleep 2

  # SET SYS CLOCK TO HW CLOCK
  test_print_trc "Set HW clock from SYS clock"
  do_cmd "hwclock --systohc"
  if [ $? -eq 0 ]; then
    test_print_trc "SYS clock to HW clock was successfully set"
  else
    die "Can't set SYS clock to HW clock"
  fi

  sleep 2

  # COMPARE NEW TIMES OF HARDWARE AND SYSTEM CLOCK
  do_cmd "NEW_HW_CLOCK=$(hwclock | awk '{print $5}' | cut -d':' -f1-2)"
  test_print_trc "New HW time $NEW_HW_CLOCK"
  do_cmd "NEW_SYS_CLOCK=$(date +%H:%M)"
  test_print_trc "New SYS time $NEW_SYS_CLOCK"
  if [[ ${NEW_HW_CLOCK} == ${NEW_SYS_CLOCK} ]]; then
    test_print_trc "HW clock to SYS clock have the same time"
  else
    die "HW clock to SYS clock don't have the same time"
  fi

  sleep 2

  # SET BACK SYS CLOCK
  test_print_trc "Set back the current time"
  do_cmd "date +%H%M%S -s $CUR_SYS_CLOCK"
  if [ $? -eq 0 ]; then
    test_print_trc "Time was successfully set back"
  else
    die "Can't set back time to SYS clock"
  fi

  sleep 2

  # SET BACK SYS CLOCK TO HW CLOCK
  do_cmd "hwclock --systohc"
  if [ $? -eq 0 ]; then
    test_print_trc "SYS clock to HW clock was successfully set back"
  else
    die "Can't setback SYS clock to HW clock"
  fi

  x=$((x+1))
done
