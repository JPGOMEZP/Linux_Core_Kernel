#!/bin/bash

###############################################################################
#
# Copyright (C) 2011 Texas Instruments Incorporated - http://www.ti.com/
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

# Author: LTP-DDT
#
# Jan, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Ported from LTP-DDT project.
#     - Modified script to align to LCK standard.
#     - Added logic to get a device node of a second SSD and HDD depending on
#       the platform.
# May, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Change the way to get SATA device node with 'lsblk' command
# Sep, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Changed device node for USB storage device

############################# DESCRIPTION #####################################

# This script get the Device Node of SSD or HDD depending on the platform.
#
#   - find_scsi_node(): get the device node of SSD or HDD

############################# FUNCTIONS #######################################

find_scsi_node() {

  SCSI_DEVICE=$1


    case $SCSI_DEVICE in
      ssd1) DEV_NODE="/dev/""$(lsblk | grep sda4 | sed 's/└─//g' | sed 's/├─//g' | awk '{print $1}')"
	    echo $DEV_NODE
            exit 0
            ;;

      ssd2) DEV_NODE="/dev/""$(lsblk | grep sdb1 | sed 's/└─//g' | sed 's/├─//g' | awk '{print $1}')"
	    echo $DEV_NODE
            exit 0
            ;;

      hdd1) DEV_NODE="/dev/""$(lsblk | grep sdb4 | sed 's/└─//g' | sed 's/├─//g' | awk '{print $1}')"
	    echo $DEV_NODE
            exit 0
            ;;

      usb1) DEV_NODE="/dev/""$(lsblk | grep sdc1 | sed 's/└─//g' | sed 's/├─//g' | awk '{print $1}')"
            echo $DEV_NODE
            exit 0
   	    ;;

      mmc1) DEV_NODE="/dev/""$(lsblk | grep mmcblk1p1 | sed 's/└─//g' | sed 's/├─//g' | awk '{print $1}')"
            echo $DEV_NODE
	    exit 0
   	    ;;

    esac
  echo "Could not find device node for SCSI device!"
  exit 1
}

############################ DO THE WORK ######################################

source "common.sh"

if [ $# -ne 2 ]; then
    echo "Error: Invalid Argument Count"
    echo "Syntax: $0 <device_type>"
    exit 1
fi

DEVICE_TYPE=$1
DEVICE_NUM=$2

case $DEVICE_TYPE in
  sata) DEV_NODE=`find_scsi_node "$DEVICE_NUM"` || die "error getting sata device node"
        ;;
  hdd)  DEV_NODE=`find_scsi_node "hdd1"` || die "error getting hard drive device node"
        ;;
  usb)  DEV_NODE=`find_scsi_node "usb1"` || die "error getting usb device node"
	;;
  mmc)  DEV_NODE=`find_scsi_node "mmc1"` || die "error getting mmc device node"
	;;
  *)    die "Invalid device type in $0 script"
        ;;
esac

if [ -n "$DEV_NODE" ]; then
  echo $DEV_NODE
else
  die "Was not able to get devnode to test. Backtrace:: $DEV_NODE ::"
fi
