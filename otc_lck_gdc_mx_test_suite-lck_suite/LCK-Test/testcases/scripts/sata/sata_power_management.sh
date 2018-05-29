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
# Jan, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Initial draft.
#     - Modified script to align to LCK standard.

############################# DESCRIPTION #####################################

# This script check if D0 is supported for SATA device reading the
# 'Runtime_Active_Counter' file.

############################# FUNCTIONS #######################################

############################ DO THE WORK ######################################

source "common.sh"

# GET SATA ID
SATA_ID=`lspci | grep SATA | awk '{print $1}'`
test_print_trc "SATA ID is: $SATA_ID"

# READ 'Runtime_Active_Counter' ONE TIME
cd /sys/bus/pci/devices/0000:$SATA_ID/power
RUN_ACT_TIME_1=`cat runtime_active_time`
test_print_trc "First read of Runtime_Active_Counter at value:$RUN_ACT_TIME_1"

test_print_trc "Waiting 10 seconds"
sleep 10

# READ 'Runtime_Active_Counter' SECOND TIME
RUN_ACT_TIME_2=`cat runtime_active_time`
test_print_trc "Second read of Runtime_Active_Counter at value:$RUN_ACT_TIME_2"

# COMPARE READINGS
if [ $RUN_ACT_TIME_1 != $RUN_ACT_TIME_2 ]; then
  test_print_trc "SATA driver supports D0"
else
  test_print_trc "SATA driver DOES NOT support D0"
fi
