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
#   Juan Pablo Gomez (juan.p.gomez@intel.com)
#     - Ported from LTP-DDT projecto to LCK project.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Modified script in order to align it to LCK repository standard.

############################ DESCRIPTION ######################################

# This script checks for all eth interfaces supported and creates an array.

############################# FUNCTIONS #######################################

############################ DO THE WORK ######################################

set +x

# CHECK FOR ALL ETH INTERFACES SUPPORTED AND CREATE AND ARRAY
J=0
for device in `find /sys/class/net/*eth*`
do
  INTERFACE=`echo $device | cut -c 16-`
  if [[ "`cat /sys/class/net/$INTERFACE/operstate`" == "up" ]]
  then
    INT_NAME[J]=$INTERFACE
    J+=1
  fi
done
echo "${INT_NAME[@]}"
