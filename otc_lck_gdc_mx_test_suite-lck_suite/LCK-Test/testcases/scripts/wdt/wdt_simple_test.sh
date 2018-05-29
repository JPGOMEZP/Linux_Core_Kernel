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
#   - Initial draft.
# Apr, 2016. Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#   - Added logic to get the current device node dinamically.
#   - Added 'compile_wdt_binary()' function, this function compiles binaries
#     'watchdog-test' and 'watchdog-simple' depending on the current WDT
#     device node.

############################ DESCRIPTION ######################################

# This script execute 'watchdog_simple' and 'watchdog-test'
# from 'wdt_test_suite'.

############################# FUNCTIONS #######################################

usage()
{
  cat<<_EOF
  Usage:./${0##*/} [-s] [-t] [-m] [-k] [-h]
  Option:
    -s	Use watchdog-simple
    -t  Use watchdog-test
		-m	Magic close
    -k  Skip Load/Unload module
    -h  Look for usage
_EOF
}

wdt_simple_test()
{
  local bin=$1
  test_print_trc "Execute \"$bin\""
  do_cmd "$bin &"
  test_print_trc "Wait for timeout: $TIMEOUT | SYSTEM MUST NOT REBOOT"
  while [ $TIMEOUT -gt 0 ]; do
	  sleep 1
		TIMEOUT=$[$TIMEOUT - 1]
	done
	PID=$(ps aux | grep $bin | head -1 | awk '{print $2}')
	test_print_trc "Wait has finished"
	do_cmd "kill -15 $PID"
	if [ $? -eq 0 ]; then
		test_print_trc "Test $bin has died"
    test_print_trc "SYSTEM WILL REBOOT UNLESS WDT DRIVER IS UNLOADED"
	fi
}

compile_wdt_binary()
{
  local dev_node=$1
  local need_compile=""

  test_print_trc "WDT Device Node: $dev_node"
  do_cmd "cd $WDT_SUITE"
  dev_node_in_bin=`grep $dev_node watchdog-simple.c | cut -d'"' -f2`

  if [[ $dev_node == $dev_node_in_bin ]]; then
    test_print_trc "No need to compile watchdog-simple nor watchdog-test"
  else
    test_print_trc "Compiling watchdog-simple and watchdog-test"
    if [ $dev_node == "/dev/watchdog0" ]; then
      sed -i 's/watchdog1/watchdog0/g' watchdog-simple.c
      sed -i 's/watchdog1/watchdog0/g' watchdog-test.c
    elif [ $dev_node == "/dev/watchdog1" ]; then
      sed -i 's/watchdog0/watchdog1/g' watchdog-simple.c
      sed -i 's/watchdog0/watchdog1/g' watchdog-test.c
    fi
    gcc watchdog-simple.c -o watchdog-simple
    gcc watchdog-test.c -o watchdog-test
  fi

  do_cmd "cd -"
}

############################ DO THE WORK ######################################

source "common.sh"

TIMEOUT=30

while getopts :stmkh arg
do case $arg in
  s)  SIMPLE=1;;
  t)  TEST=1;;
	m)	MAGIC=1;;
  k)  SKIP=1;;
  h)  usage;;
  :)  test_print_trc "$0: Must supply an argument to -$OPTARG." >&2
      exit 1
      ;;
  \?) test_print_trc "Invalid Option -$OPTARG ignored." >&2
      usage
      exit 1
      ;;
esac
done

: ${SIMPLE:='0'}
: ${TEST:='0'}
: ${MAGIC:='0'}
: ${SKIP:='0'}

# SKIP LOAD DRIVER
if [ $SKIP -eq 0 ]; then
  do_cmd load_unload_module.sh -l -d wdat_wdt
fi

# GET WDT DEVICE NODE
DEV=`ls $WDT_DEV | grep "watchdog1"`
if [ ! -z $DEV ]; then
  DEV_NODE="/dev/${DEV}"
else
  DEV_NODE="/dev/watchdog0"
fi

# COMPILE WDT BINARY WITH THE RIGHT DEVICE NODE
compile_wdt_binary "$DEV_NODE"

# EXECUTE 'watchdog-simple'
if [ $SIMPLE -eq 1 ]; then
	wdt_simple_test	"watchdog-simple"

# EXECUTE 'watchdog-test'
elif [ $TEST -eq 1 ]; then
	wdt_simple_test "watchdog-test"

# EXECUTE 'watchdog-simple' WITH "Magic Close"
elif [ $MAGIC -eq 1 ]; then
	do_cmd "cd $WDT_SUITE"
	sed -i 's/\"\\0\"/\"V\"/g' watchdog-simple.c
	gcc watchdog-simple.c -o watchdog-simple
	do_cmd "wdt_tests -device $DEV_NODE -ioctl settimeout -ioctlarg "40""
	wdt_simple_test "watchdog-simple"
  sed -i 's/\"V\"/\"\\0\"/g' watchdog-simple.c
  gcc watchdog-simple.c -o watchdog-simple
	do_cmd "cd -"
	do_cmd load_unload_module.sh -u -d wdat_wdt
fi

# WAIT FOR TIMEOUT UNTIL SYSTEM REBOOTS
if [ $MAGIC -eq 0 ]; then
  TIMEOUT=30
  while [ $TIMEOUT -gt 0 ]; do
    test_print_trc "$TIMEOUT SECONDS TO REBOOT"
    sleep 1
	  TIMEOUT=$[$TIMEOUT - 1]
  done
fi
