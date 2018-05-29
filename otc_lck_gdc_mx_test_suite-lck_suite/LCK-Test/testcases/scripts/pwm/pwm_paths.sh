#!/bin/bash

################################################################################
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

# Jun, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Initial draft

############################# DESCRIPTION #####################################

# This script looks for corresponding PWM paths

############################# FUNCTIONS #######################################

usage()
{
cat <<-EOF >&2
  usage: ./${0##*/} [-c] [-p] [-r] [-b]
    -c	to look for PWM PCI path
    -p 	to look for PWM Platform path
    -r 	to look for PWM regulator driver path
    -b 	to look for PWM backlight driver path
    -h 	print this usage
EOF
exit 0
}

############################ DO THE WORK ######################################

source "common.sh"

while getopts :cprbh arg
do case $arg in
	c) PCI=1 ;;
   	p) PLATFORM=1;;
	r) REGULATOR=1;;
	b) BACKLIGHT=1;;
 	h) usage;;
	:) test_print_trc "$0: Must supply an argument to -$OPTARG." >&2
           exit 1
           ;;
        \?) test_print_trc "Invalid Option -$OPTARG ignored." >&2
            usage
            exit 1
            ;;
   esac
done

# DEFAULT VALUES IF NOT SET IN 'getopts'
: ${PCI:='0'}
: ${PLATFORM:='0'}
: ${REGULATOR:='0'}
: ${BACKLIGHT:='0'}

if [ $PCI -eq 1 ]; then
  do_cmd ls $PWM_PCI | grep pwm-lpss
  if [ $? -eq 0 ]; then
    test_print_trc "The PCI driver for Intel Low Power Subsystem PWM controller path exists"
  else
    die "The PCI driver for Intel Low Power Subsystem PWM controller path DO NOT exists"
  fi
elif [ $PLATFORM -eq 1 ]; then
  do_cmd ls $PWM_PLATFORM | grep pwm-lpss
  if [ $? -eq 0 ]; then
    test_print_trc "The ACPI platform driver for Intel Low Power Subsystem PWM controller path exists"
  else
    die "The ACPI platform driver for Intel Low Power Subsystem PWM controller path DO NOT exists"
  fi
elif [ $REGULATOR -eq 1 ]; then
  do_cmd ls $PWM_PLATFORM | grep pwm-regulator
  if [ $? -eq 0 ]; then
    test_print_trc "The ACPI platform driver for PWM regulator controller path exists"
  else
    die "The ACPI platform driver PWM regulator controller path DO NOT exists"
  fi
elif [ $BACKLIGHT -eq 1 ]; then
  do_cmd ls $PWM_PLATFORM | grep pwm-backlight
  if [ $? -eq 0 ]; then
    test_print_trc "The ACPI platform driver for PWM backlight controller path exists"
  else
    die "The ACPI platform driver PWM backlight controller path DO NOT exists"
  fi
fi
