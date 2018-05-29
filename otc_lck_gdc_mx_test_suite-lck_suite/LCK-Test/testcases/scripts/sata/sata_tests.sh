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
# Jan, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Initial draft.
# Jul, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Updated script to achieve a more automated test suite
# Sep, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Updated script. 'Added sata_scenario_modifier.sh' call.

############################ DESCRIPTION ######################################

# This script runs different test types depending on test type and
# kernel_type parameters.

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
  run_test "sata-func-builtin-tests"
elif [ $KERNEL_TYPE == "module" ]; then
  case $TEST_TYPE in
    func)   echo "1" > $SATA_SCRIPTS/sata_test_suite_tracker
	    echo "sata-func-tests" > $SATA_SCRIPTS/sata_test_scenario_tracker
            $SATA_SCRIPTS/sata_scenario_modifier.sh
	    run_test "sata-func-tests"
            $SATA_SCRIPTS/sata_scenario_modifier.sh ;;
    perf)   run_test "sata-perf-tests" ;;
    stress) run_test "sata-stress-tests" ;;
    bat)    #echo "1" > $SATA_SCRIPTS/sata_test_suite_tracker
	    #echo "sata-bat-tests" > $SATA_SCRIPTS/sata_test_scenario_tracker
    	    #$SATA_SCRIPTS/sata_scenario_modifier.sh
  	    run_test "sata-bat-tests" ;;
    full)   echo "1" > $SATA_SCRIPTS/sata_test_suite_tracker
 	    echo "sata-full-tests" > $SATA_SCRIPTS/sata_test_scenario_tracker
            $SATA_SCRIPTS/sata_scenario_modifier.sh
	    run_test "sata-full-tests"
	    $SATA_SCRIPTS/sata_scenario_modifier.sh ;;
  esac
fi
