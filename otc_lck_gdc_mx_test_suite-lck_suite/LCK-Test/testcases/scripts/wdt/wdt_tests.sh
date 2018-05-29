#!/bin/bash

###############################################################################
#
# Copyright (C) 2015 Intel - http://www.intel.com/
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
# Jan, 2016. Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#   - Created to run different test types
# Apr, 2016. Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#   - Add logic to write in tracker files in order to keep the test status
# Sep, 2016. Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#   - Updated script, added 'wdt_scenario_modifier.sh' call

############################ DESCRIPTION ######################################

# This script runs different test types depending on $TEST_TYPE and
# $KERNEL_TYPE parameters.

############################# FUNCTIONS #######################################

usage()
{
cat<<_EOF
  Usage:./${0##*/} [DRIVER] [TEST_TYPE] [KERNEL_TYPE]
  Option:
    DRIVER      Driver to test.
    TEST_TYPE   Test type to execute.
    KERNEL_TYPE Kernel type to use.
_EOF
}

############################ DO THE WORK ######################################

source "common.sh"

DRIVER=$1
TEST_TYPE=$2
KERNEL_TYPE=$3

echo -e "\n----------------------------"
test_print_trc "DRIVER: $DRIVER"
echo "----------------------------"

if [ $KERNEL_TYPE == "builtin" ]; then
  run_test "wdt-func-builtin-tests"
elif [ $KERNEL_TYPE == "module" ]; then
  case $TEST_TYPE in
    func)   echo "1" > $WDT_SCRIPTS/wdt_test_suite_tracker
            echo "wdt-func-tests" > $WDT_SCRIPTS/wdt_test_scenario_tracker
            run_test "wdt-func-tests" ;;
    perf)   run_test "wdt-perf-tests" ;;
    stress) run_test "wdt-stress-tests" ;;
    bat)    #echo "1" > $WDT_SCRIPTS/wdt_test_suite_tracker
            #echo "wdt-bat-tests" > $WDT_SCRIPTS/wdt_test_scenario_tracker
	    #$WDT_SCRIPTS/wdt_scenario_modifier.sh
            run_test "wdt-bat-tests" ;;
    full)   echo "1" > $WDT_SCRIPTS/wdt_test_suite_tracker
            echo "wdt-full-tests" > $WDT_SCRIPTS/wdt_test_scenario_tracker
            run_test "wdt-full-tests" ;;
  esac
fi
