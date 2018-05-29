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

# Author: sylvainx.heude@intel.com
#
# Jan, 2016. Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#   - Ported from 'otc_kernel_qa-tp_tc_scripts_linux_core_kernel' project to
#     LCK project.
#   - Modified script in order to align it to LCK repository standard.

############################ DESCRIPTION ######################################

# This script looks for EC path

############################ FUNCTIONS ########################################

############################ DO THE WORK ######################################

source "common.sh"

# LOOK FOR EC DIRECTORY
do_cmd ls -l $EC_DIR
if [ $? -eq 0 ]; then
  test_print_trc "Path to EC directory exists"
else
  die "Path to EC directory not found"
fi
