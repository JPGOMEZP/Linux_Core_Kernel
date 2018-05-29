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
# Desciption: Script to run Linux Core Kernel Tests.
# Ingredients: WDT,SATA,PCIe,LPC,MEI,RTC,EC.
#
###############################################################################

############################ CONTRIBUTORS #####################################

# Author: Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#
# Jan, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Initial draft.
#     - modified script to align it to LCK standard.
# Mar, 2016
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Added logic to creat directory for logs
# Apr, 2016
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Added logic to call script to convert logs into CSV files
#     - Disable temporaryly call to 'log_to_csv.sh' script.
# May, 2016
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Removed 'case' statement and substituted by one-line call.
# Aug, 2016
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Added logic to read driver component from <platform/> file and execute
#       such component.
#     - Replaced some code to function calls: get_platform() and get_kernel_in_use()
#     - Added code to stop execution when SATA finish
# Sep, 2016
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Added 'LOGS' variable in this script

############################# DESCRIPTION #####################################

# This script exports both paths and variables for a corresponding driver.

############################# FUNCTIONS #######################################

usage()
{
cat<<_EOF
  Usage:./${0##*/} [-t] [-h]
  Options:
    -t  Test type to execute.
    -h  Print this usage.
_EOF
}

############################ DO THE WORK ######################################


while getopts :t:h arg
do case $arg in
  t)  TEST_TYPE="$OPTARG" ;;
  h)  usage
      exit 1 ;;
  :)  echo "$0: Must supply an argument to -$OPTARG." >&2
      exit 1 ;;
 \?)  echo "Invalid Option -$OPTARG ignored." >&2
      usage
      exit 1 ;;
esac
done

# EXPORT COMMON FUNCTIONS
export PATH="$PATH:$PWD/LCK-Test/testcases/scripts/common"
source "common.sh"

# LOG TEST
LOGS="$HOME/LCK-Reports"
LOG_NAME=`date '+%Y_%m_%d_%H_%M_%S'`
LOG_LOCATION="$LOGS/$LOG_NAME"

# CREATE DIRECTORY FOR REPORTS
if [ ! -d $LOGS ]; then
  mkdir -p $LOGS
fi

# GET PLATFORM UNDER TEST
DUT=$(get_platform)

# GET KERNEL IN USE
KERNEL_TYPE=$(get_kernel_in_use)

# PRINT TEST ENVIRONMENT
test_environment

# EXECUTE DRIVER TESTS
while read driver
do
  regx='^#'
  if ! [[ $driver =~ $regx ]]; then

    source export_paths.sh "$driver"
    ${driver}_tests.sh "$driver" "$TEST_TYPE" "$KERNEL_TYPE" | tee $LOG_LOCATION

#    if [[ $driver == "sata" ]]; then
#      break
#    fi
  fi
done < ${PWD}/platforms/${DUT}

#echo -e "\n\n================== TEST SUMMARY ==================\n"

#log_to_csv.sh "$LOG_LOCATION"
