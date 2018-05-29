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

# Author: sylvainx.heude@intel.com
#
# Jan, 2016. Juan Carlos Alonso
#   - Created to run different test types

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
  run_test "mei-func-builtin-tests"
elif [ $KERNEL_TYPE == "module" ]; then
  case $TEST_TYPE in
    func)   run_test "mei-func-tests" ;;
    perf)   run_test "mei-perf-tests" ;;
    stress) run_test "mei-stress-tests" ;;
    bat)    run_test "mei-bat-tests" ;;
    full)   run_test "mei-full-tests" ;;
  esac
fi
