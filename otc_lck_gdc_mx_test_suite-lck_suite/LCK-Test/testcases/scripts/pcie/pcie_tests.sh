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

############################# CONTRIBUTORS ####################################

# Author:  Juan Pablo Gomez (juan.pablo.gomez@intel.com)
#
# Jan, 2016.
#   Juan Pablo Gomez <juan.p.gomez@intel.com>
#     - Created to run different test types
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Modified script to align to the LCK standard.

############################# DESCRIPTION #####################################

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
  run_test "pcie-func-builtin-tests"
elif [ $KERNEL_TYPE == "module" ]; then
  case $TEST_TYPE in
    func)   run_test "pcie-func-tests" ;;
    perf)   run_test "pcie-perf-tests" ;;
    stress) run_test "pcie-stress-tests" ;;
    bat)    run_test "pcie-bat-tests" ;;
    full)   run_test "pcie-full-tests" ;;
  esac
fi
