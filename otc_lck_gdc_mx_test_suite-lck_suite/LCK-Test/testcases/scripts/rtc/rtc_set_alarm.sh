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
# May, 2016. Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#   - Improved script in order to execute a more accurate test and show more
#     information about what it is doing.
#   - Added a loop option in order to perform stress test.

############################ DESCRIPTION ######################################

# This script set a wake up alarm.

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

x=0

while [ $x -lt $LOOP ]
do
  # DISABLE WAKE UP ALARM
  test_print_trc "Disable wake up alarm"
  test_print_trc "sh -c \"echo 0 > $ALARM\""
#  sh -c "echo 0 > $ALARM"
  echo 0 > $ALARM
  if [ $? -eq 0 ]; then
    test_print_trc "Wake up alarm was successfully disable"
  else
    die "Can't disable wake up alarm"
  fi

  test_print_trc "cat $PROC_RTC | grep alarm_IRQ"
  do_cmd "ALARM_IRQ=$(cat $PROC_RTC | grep alarm_IRQ | awk '{print $3}')"
  test_print_trc "ALARM_IRQ: $ALARM_IRQ"

  sleep 2

  # SET A WAKE UP ALARM
  test_print_trc "Set a wake up alarm"
  test_print_trc "sh -c \"echo \$(date +'%s' -d '1 minutes')>$ALARM"
#  sh -c "echo $(date +'%s' -d '1 minutes')>$ALARM"
  echo $(date +'%s' -d '1 minutes')>$ALARM
  if [ $? -eq 0 ]; then
    test_print_trc "Wake up alarm was successfully set"
  else
    die "Can't set wake up alarm"
  fi

  # CHECK IF WAKE UP ALARM WAS SET
  ALARM_IRQ=$(cat $PROC_RTC | grep "alarm_IRQ" | awk '{print $3}')
  ALARM_DATE=$(cat $PROC_RTC | grep "alrm_date" | awk '{print $3}')
  ALARM_TIME=$(cat $PROC_RTC | grep "alrm_time" | awk '{print $3}')
  RTC_TIME=$(cat $PROC_RTC | grep "rtc_time" | awk '{print $3}')

  test_print_trc "ALARM_IRQ: $ALARM_IRQ"
  test_print_trc "ALARM_DATE: $ALARM_DATE"
  test_print_trc "ALARM_TIME: $ALARM_TIME"
  test_print_trc "RTC_TIME: $RTC_TIME"

  # MAKE A SUSPEND AND RESUME AFTER WAKE UP ALARM TIME
  sleep 5
  do_cmd "echo mem > /sys/power/state"
  if [ $? -eq 0 ]; then
    test_print_trc "System returned correctly from suspend"
  else
    die "Can't set wake up alarm"
  fi

  x=$((x+1))
done
