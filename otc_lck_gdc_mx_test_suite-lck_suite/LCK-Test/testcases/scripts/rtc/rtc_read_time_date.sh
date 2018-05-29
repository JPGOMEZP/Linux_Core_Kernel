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

# Author: Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#
# May, 2016. Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#   - Initial draft

############################ DESCRIPTION ######################################

# This script reads time and date from '/proc/driver/rtc',
# '/sys/class/rtc/rtc0/', 'date' command and 'hwclock' command.

############################ FUNCTIONS ########################################

############################ DO THE WORK ######################################

source "common.sh"

# READ TIME WITH `date`
test_print_trc "=== Read time with 'date' command ==="
test_print_trc "date +%H:%M:%S"
do_cmd "TIME=$(date +%H:%M:%S)"
if [ $? -eq 0 ]; then
  test_print_trc "Time is $TIME"
else
  die "Cannot read time with 'date' command"
fi

sleep 2

# READ DATE WITH `date`
test_print_trc "=== Read date with 'date' command ==="
test_print_trc "date +%Y-%m-%d"
do_cmd "DATE=$(date +%Y-%m-%d)"
if [ $? -eq 0 ]; then
  test_print_trc "Date is $DATE"
else
  die "Cannot read date with 'date' command"
fi

sleep 2

# READ TIME WITH `hwclock`
test_print_trc "=== Read time with 'hwclock' command ==="
test_print_trc "hwclock -r | awk '{print \$5}'"
do_cmd "TIME=$(hwclock -r | awk '{print $5}')"
if [ $? -eq 0 ]; then
  test_print_trc "Time is $TIME"
else
  die "Cannot read time with 'hwclock' command"
fi

sleep 2

# READ DATE WITH `hwclock`
test_print_trc "=== Read date with 'hwclock' command ==="
test_print_trc "hwclock -r | awk '{print \$2 \$3 \$4}'"
do_cmd "DATE=$(hwclock -r | awk '{print $2 $3 $4}')"
if [ $? -eq 0 ]; then
  test_print_trc "Date is $DATE"
else
  die "Cannot read date with 'hwclock' command"
fi

sleep 2

# READ TIME IN '/proc/driver/rtc'
test_print_trc "=== Read time in '$PROC_RTC' file ==="
test_print_trc "cat $PROC_RTC | grep rtc_time"
do_cmd "TIME=$(cat $PROC_RTC | grep "rtc_time" | awk '{print $3}')"
if [ $? -eq 0 ]; then
  test_print_trc "RTC TIME is $TIME"
else
  die "Cannot read RTC time in '$PROC_RTC' file"
fi

sleep 2

# READ DATE IN '/proc/driver/rtc'
test_print_trc "=== Read date in '$PROC_RTC' file ==="
test_print_trc "cat $PROC_RTC | grep rtc_date"
do_cmd "DATE=$(cat $PROC_RTC | grep "rtc_date" | awk '{print $3}')"
if [ $? -eq 0 ]; then
  test_print_trc "RTC DATE is $DATE"
else
  die "Cannot read RTC date in '$PROC_RTC' file"
fi

sleep 2

# READ TIME IN '/sys/class/rtc/rtc0'
test_print_trc "=== Read time in '$SYS_RTC' ==="
test_print_trc "cat $SYS_RTC/time"
do_cmd "TIME=$(cat $SYS_RTC/time)"
if [ $? -eq 0 ]; then
  test_print_trc "RTC TIME is $TIME"
else
  die "Cannot read RTC time in '$SYS_RTC'"
fi

sleep 2

# READ DATE IN '/sys/class/rtc/rtc0'
test_print_trc "=== Read date in '$SYS_RTC' file ==="
test_print_trc "cat $SYS_RTC/date"
do_cmd "DATE=$(cat $SYS_RTC/date)"
if [ $? -eq 0 ]; then
  test_print_trc "RTC DATE is $DATE"
else
  die "Cannot read RTC date in '$SYS_RTC' file"
fi
