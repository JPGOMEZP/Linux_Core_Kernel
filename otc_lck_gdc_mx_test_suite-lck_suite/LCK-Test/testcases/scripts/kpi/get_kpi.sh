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

# Author: juan.carlos.alonso@intel.com
#
# Jul, 2016. Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#   - Initial draft

############################ DESCRIPTION ######################################

# This script suspend/resume the system to get KPI measures.

############################ FUNCTIONS ########################################

############################ DO THE WORK ######################################

#set -x

# NUM OF LOOP
PLATFORM=$1
NUM=$2

# CLEAR 'kpi_file' if LOOP is 1
if [ -a "${HOME}/kpi_file" -a "${NUM}" -eq 1 ]; then
  echo > ${HOME}/kpi_file
fi

# SUSPEND SYSTEM
echo "System Suspend: $NUM"
rtcwake -m mem -s 30

# EXECUTE 'get_measures.sh'
echo "System Resume: $NUM"
sleep 3
echo "Getting KPI measures..."
./get_measures.sh kpi_${PLATFORM}/ >> ~/kpi_file
echo $NUM > reboots
sleep 3

# EXECUTE 'get_kpi_average.sh'
if [ `cat reboots` -eq 5 ]; then
  ./get_kpi_average.sh ${HOME}/kpi_file
else
  reboot
fi
