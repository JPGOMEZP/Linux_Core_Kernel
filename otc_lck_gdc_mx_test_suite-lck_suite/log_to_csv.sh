#!/bin/bash

###############################################################################
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
# Apr, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Initial draft.
#     - Added logic to display a test summary after execution.

############################# DESCRIPTION #####################################

# This script converts the log file into CSV file to be uploaded to TRC

############################# FUNCTIONS #######################################

############################ DO THE WORK ######################################

source "common.sh"

LOG_FILE=$1

# GET NAME FOR CSV FILE
PLATFORM=$(grep "PLATFORM:" $LOG_FILE | cut -d' ' -f3 | sed 's/|//g')
WW="WW16"
TEST_TYPE=$(grep "TEST TYPE:" $LOG_FILE | cut -d' ' -f4 | sed 's/|//g')
TEST_EXECUTED=$(grep "DRIVER:" $LOG_FILE | cut -d' ' -f3 | sed 's/|//g')
KERNEL_VERSION=$(grep "KERNEL_VERSION:" $LOG_FILE | cut -d' ' -f3 | sed 's/|//g')

# CREATE CSV FILE
FILE=`echo ${PLATFORM}_${WW}_${TEST_TYPE}_${TEST_EXECUTED} | tr '[:lower:]' '[:upper:]'`
CSV_FILE="${FILE}_${KERNEL_VERSION}.csv"
LAST_CSV_FILE=$(ls results/$TEST_TYPE | grep -i "${TEST_TYPE}_${TEST_EXECUTED}")
CSV_FILE_DIR="results/${TEST_TYPE}/${CSV_FILE}"

# CREATE CSV FILE IF DOES NOT EXISTS
if ! [ -e "${CSV_FILE_DIR}" ]; then
  cd results/${TEST_TYPE}
  mv ${LAST_CSV_FILE} ${CSV_FILE}
  cd -
fi

# DISPLAY A TEST SUMMARY
while read line
do
  regx='Component'
  if ! [[ $line =~ $regx ]]; then
    TEST=`echo $line | cut -d',' -f2`
    STATUS=`grep "TEST $TEST" $LOG_FILE | cut -d' ' -f5`

    if [[ "$STATUS" == "PASS" ]]; then
      printf "%-45s\t0\n" "$TEST"
    elif [[ "$STATUS" == "FAIL" ]]; then
      printf "%-45s\t1\n" "$TEST"
    elif [[ "$STATUS" == "BLOCK" ]]; then
      printf "%-45s\t1\n" "$TEST"
    fi
  fi
done < "${CSV_FILE_DIR}"
