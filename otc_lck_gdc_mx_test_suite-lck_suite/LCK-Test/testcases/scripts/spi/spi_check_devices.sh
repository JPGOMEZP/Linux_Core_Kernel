#!/bin/bash

################################################################################
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

# Jul, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Initial draft

############################# DESCRIPTION #####################################

# This script checks how many SPI devices are supported by platform

############################# FUNCTIONS #######################################

############################ DO THE WORK ######################################

source "common.sh"

declare -a SPI_DEVICES

# LOAD SPI PLATFORM DRIVER
load_unload_module.sh -l -d "spi-pxa2xx-platform"

# FIND SPI DEVICES
test_print_trc "Find SPI devices in $SPI_MASTER"
do_cmd "ls $SPI_MASTER"

SPI_DEVICES=$(ls $SPI_MASTER)

# FIND WHAT DRIVERS ARE BOUNDED TO THE CONTROLLER
test_print_trc "The devices bound to drivers are:"
for i in ${SPI_DEVICES[@]}
do
  DRIVER=$(ls -l $SPI_MASTER | grep $i |  cut -d'/' -f6)
  test_print_trc "$i -> $DRIVER"
done

# UNLOAD SPI PLATFORM DRIVER
load_unload_module.sh -u -d "spi-pxa2xx-platform"
