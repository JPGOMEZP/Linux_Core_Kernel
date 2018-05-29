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

# This script checks if SATA CD-ROM is supported. It gets CD-ROM device node,
# ID and open CD-ROM tray.

############################# FUNCTIONS #######################################

############################ DO THE WORK ######################################

source "common.sh"

# LOAD DRIVER
load_unload_module.sh -l -d "ahci"

test_print_trc "CDROM initialization dmesg"
dmesg | grep "cdrom"

# GET CD-ROM DEVICE NODE
SR0=`ls /dev | grep sr0`
if [ $SR0 == "sr0" ]; then
	test_print_trc "CD-ROM device in \"/dev\" is $SR0"
else
	die "CD-ROM device not found"
fi

# GET CD-ROM ID
CDROM_ID=`ls -l /dev/disk/by-id | grep sr0 | awk '{print $9}'`
if [ ! -z $CDROM_ID ]; then
	test_print_trc "CD-ROM ID is: $CDROM_ID"
else
	die "Could not find CD-ROM ID"
fi

# OPEN CD-ROM TRAY
test_print_trc "Open CD-ROM tray"
eject /dev/$SR0
if [ "$?" -eq 0 ]; then
	test_print_trc "CD-ROM tray oppened successfully"
else
	die "Could not open CD-ROM tray"
fi
