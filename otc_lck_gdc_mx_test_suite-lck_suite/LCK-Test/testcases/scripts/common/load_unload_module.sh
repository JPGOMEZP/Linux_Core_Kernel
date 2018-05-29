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
# Jan, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Initial drafti.
#     - Added 'load_module()' and 'unload_module()' functions.
#     - Added 'check_lsmod()' function.

############################ DESCRIPTION ######################################

# This script load/unload driver module.
#
#   - load_module(): load driver module with or without parameters.
#
#   - unload_module(): unload driver module.
#
#   - check_lsmod(): check if driver is loaded/unloaded with 'lsmod'.

############################# FUNCTIONS #######################################

usage()
{
  cat<<_EOF
  Usage:./${0##*/} [-l] [-u] [-b TIMEOUT] [-w NOWAYOUT ] [-p USE_PARAMS] [-h]
  Option:
    -l	Load module
    -u	Unload module
		-b 	Set a Timeout with Heartbeat kernel parameter
		-w	Set Nowayout kernel watchdog parameter
		-p	Use kernel parameters
    -h	look for usage
_EOF
}

# LOAD DRIVER MODULE
load_module()
{
  local mod=$1
	local hbeat=$2
	local nwout=$3

	if [ $# -eq 1 ]; then
		do_cmd sudo modprobe $mod
	elif [ $# -eq 3 ]; then
		do_cmd sudo modprobe $mod heartbeat="$hbeat" nowayout="$nwout"
	fi

  if [ $? -eq 0 ]; then
    test_print_trc "$mod	: Loaded"
		mod_loaded=$(echo $mod | tr '-' '_')
		check_lsmod "$mod_loaded"
  else
    die "$mod cannot be loaded"
  fi
}

# UNLOAD DRIVER MODULE
unload_module()
{
  local mod=$1
  if [ $# -ne 1 ]; then
    test_print_trc "Please input module to be unloaded"
    return 1
  fi
	mod_loaded=$(echo $mod | tr '-' '_')
  do_cmd sudo modprobe -r $mod_loaded
  if [ $? -eq 0 ]; then
    test_print_trc "$mod	: Unloaded"
		check_lsmod "$mod_loaded"
  else
    die "$mod cannot be unloaded"
	fi
}

# CHECK DRIVER MODULE LOADED WITH 'lsmod' COMMAND
check_lsmod()
{
  local mod=$1
  if [ $# -ne 1 ]; then
    test_print_trc "Please input module to be check"
    return 1
  fi
	LSMOD=$(lsmod | grep "$mod" | head -1)
	test_print_trc "lsmod	: $LSMOD"
}

################################ DO THE WORK ##################################

source "common.sh"

while getopts :lud:b:w:ph arg
do case $arg in
	l)	LOAD=1;;
	u)	UNLOAD=1;;
  d)  DRIVER="$OPTARG";;
	b)	HBEAT="$OPTARG";;
	w) 	NWOUT="$OPTARG";;
	p)	PARAMS=1;;
	h)	usage;;
  :)  test_print_trc "$0: Must supply an argument to -$OPTARG." >&2
      exit 1
      ;;
  \?) test_print_trc "Invalid Option -$OPTARG ignored." >&2
      usage
      exit 1
      ;;
esac
done

# DEFAULT VALUES IF NOT SET IN 'getopts'
: ${LOAD:='0'}
: ${UNLOAD:='0'}
: ${PARAMS:='0'}

# LOAD MODULE DRIVER
if [ "$LOAD" -eq 1 ]; then
  if [ $DRIVER == "iTCO_wdt" ]; then
    load_module "i2c-i801"
    load_module "i2c-smbus"
    if [ $PARAMS -eq 0 ]; then
      load_module "$DRIVER"
    else
      load_module "$DRIVER" "$HBEAT" "$NWOUT"
    fi
  else
    load_module "$DRIVER"
  fi

# UNLOAD MODULE DRIVER
elif [ "$UNLOAD" -eq 1 ]; then
  if [ "$DRIVER" == "iTCO_wdt" ]; then
    unload_module "$DRIVER"
    unload_module "i2c-i801"
    unload_module "i2c-smbus"
  else
    unload_module "$DRIVER"
  fi
fi
