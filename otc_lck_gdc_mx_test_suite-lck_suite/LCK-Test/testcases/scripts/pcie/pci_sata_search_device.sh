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

############################# CONTRIBUTORS #################################### 

# Author: LTP-DDT
#
# Jan, 2016.
#   Juan Pablo Gomez (juan.p.gomez@intel.com)
#     - Ported from LTP-DDT projecto to LCK project.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Modified script in order to align it to LCK repository standard.

############################# DESCRIPTION ##################################### 

# This script search for PCI SATA devices.

############################# FUNCTIONS #######################################

############################ DO THE WORK ######################################

RIGHT_DEV=''

DEVICES=`ls /sys/block |grep sda`

for device in $DEVICES
do
  PCI_INTERFACE=`udevadm info --attribute-walk --path=/sys/block/$device | grep -m 1 -i "pci"`
    if [ -n "$PCI_INTERFACE" ]; then
      echo $device
      RIGHT_DEV=$device
    fi
done

if [ -z $RIGHT_DEV ]; then
  test_print_trc " ::"
  test_print_trc " :: Failed to find PCI SATA interface. Exiting PCI SATA tests..."
  test_print_trc " ::"

  exit 2
fi
