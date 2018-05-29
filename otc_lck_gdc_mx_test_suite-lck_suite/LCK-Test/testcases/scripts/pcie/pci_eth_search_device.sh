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
################################################################################

############################ CONTRIBUTORS #####################################

# Author: LTP-DDT
#
# Jan, 2016.
#   Juan Pablo Gomez (juan.p.gomez@intel.com)
#     - Ported from LTP-DDT projecto to LCK project.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Modified script in order to align it to LCK repository standard.

############################ DESCRIPTION ######################################

# This script search for PCI Ethernet devices

############################# FUNCTIONS #######################################

############################ DO THE WORK ######################################

ETHDEV=''
DEVICES=`ls /sys/class/net | grep eth`

for device in $DEVICES
do
  PCI_INTERFACE=`udevadm info --attribute-walk --path=/sys/class/net/$device | grep -m 1 -i "pci"`
  if [ -n "$PCI_INTERFACE" ]; then
    echo "$device"
    ETHDEV=$device
  fi
done

if [ -z $ETHDEV ];
then
  echo "::"
  echo ":: Failed to find PCI Ethernet interface. Exiting PCI Ethernet tests..."
  echo "::"
  exit 2
fi
