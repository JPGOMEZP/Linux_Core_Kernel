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

# Author: Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#
# Jan, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Initial draft.
#     - Modified script to align to LCK standard.

############################# DESCRIPTION #####################################

# This script checks the device specifications for SATA device:
#    - Device ID.
#    - Device Generation.
#    - Native Command Queueing support.
#    - AHCI Device support.
#    - HotPlug Device support.

############################# FUNCTIONS #######################################

############################ DO THE WORK ######################################

source "common.sh"

while getopts :egnath arg
do case $arg in
  e)  ENUM_DEV=1;;
  g)  GEN_DEV=1;;
  n)  NCQ_DEV=1;;
  a)  AHCI_DEV=1;;
  t)  HOTPLUG_DEV=1;;
  h)  usage;;
  \?) test_print_trc "Invalid Option -$OPTARG ignored." >&2
      usage
      exit 1 ;;
  esac
done

# DEFAULT VALUES IF NOT SET IN 'getopts'
: ${ENUM_DEV:='0'}
: ${GEN_DEV:='0'}
: ${NCQ_DEV:='0'}
: ${AHCI_DEV:='0'}
: ${HOTPLUG_DEV:='0'}

# LOOK FOR SATA ENUMERATION DEVICE
if [ $ENUM_DEV -eq 1 ]; then
  SATA_ENUM=`lspci | grep SATA | cut -d' ' -f1`
  if [ ! -z $SATA_ENUM ]; then
    test_print_trc "Enumeration of SATA port:$SATA_ENUM"
  else
    die "No PCI port was found"
  fi

# CHECK SATA GENERATION DEVICE
elif [ $GEN_DEV -eq 1 ]; then
  GEN=`hdparm -iI /dev/sda | grep "Gen3" | awk '{print $2}'`
  SPEED=`hdparm -iI /dev/sda | grep "Gen3" | awk '{print $5}' | sed 's/[()]//g'`

  test_print_trc "SATA GENERATION IS:$GEN"
  test_print_trc "SATA SPPED IS:$SPEED"

  if [ $GEN == "Gen3" ] && [ $SPEED == "6.0Gb/s" ]; then
    test_print_trc "SATA driver supports SATA Gen 3"
  else
    die "SATA driver DOES NOT support SATA Gen 3"
  fi

# CHECK IF SATA DEVICE SUPPORT NATIVE COMMAND QUEUEING
elif [ $NCQ_DEV -eq 1 ]; then
  NCQ=`hdparm -iI /dev/sda | grep "NCQ" | awk '{print $5}' | sed 's/[()]//g'`

  if [ $NCQ == "NCQ" ]; then
    test_print_trc "SATA driver supports Native Command Queueing"
  else
    die "SATA driver DOES NOT support Native Command Queueing"
  fi

# CHECK AHCI SPECIFICATION
elif [ $AHCI_DEV -eq 1 ]; then
    DEVSLP=`hdparm -iI /dev/sda | grep DEVSLP | head -1 | sed 's/\t\+//g'`
    EXIT_TIMEOUT=`hdparm -iI /dev/sda | grep "Exit Timeout" | sed 's/\t\+//g'`
    ASSERTION_TIME=`hdparm -iI /dev/sda | grep "Assertion Time" | sed 's/\t\+//g'`
    FLAGS_ARRAY=($(dmesg | grep ahci | grep flags))
    FLAGS=${FLAGS_ARRAY[@]:4}

    test_print_trc "$DEVSLP"
    test_print_trc "$EXIT_TIMEOUT"
    test_print_trc "$ASSERTION_TIME"
    test_print_trc "$FLAGS"

# CHECK IF HOT PLUG IS SUPPORTED AND ENABLED
elif [ $HOTPLUG_DEV -eq 1 ]; then
  BLOCK=`ls /sys/block/ | grep sd | head -1`
    test_print_trc "ls /sys/block/ | grep sd | head -1: $BLOCK"
    if [ ! -z $BLOCK ]; then
      IS_ENABLED=`cat /sys/block/$BLOCK/removable`
      test_print_trc "cat /sys/block/$BLOCK/removable: $IS_ENABLED"
      if [ $IS_ENABLED -eq 1 ]; then
        test_print_trc "SATA Hot-Plug Capability is enabled"
      else
        test_print_trc "SATA Hot-Plug Capability is NOT enabled"
      fi
    fi
fi
