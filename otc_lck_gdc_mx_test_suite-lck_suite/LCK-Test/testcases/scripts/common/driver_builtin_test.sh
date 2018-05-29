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
#     - Aligned it to the LCK project standard.
# Apr, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Updated script to get kernel messages for 'sdhci' driver
# Jun, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Updated script to get kernel messages for 'pwm' driver
# Aug, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Updated script to get kernel messages for 'spi' driver

############################ DESCRIPTION ######################################

# This script looks for <driver>.ko in '/lib/modules/$(uname -r)/modules.builtin'
# and messages with 'dmesg' command.

############################ DO THE WORK ######################################

source "common.sh"

DRIVER=$1

# LOOK IF A DRIVER IS CONFIGURED AS BUILT-IN
IS_BUILTIN=`grep "$DRIVER" "$BUILTIN_DIR" | head -1`
if [ ! -z "$IS_BUILTIN" ]; then
  test_print_trc "Driver $DRIVER configured as built-in: $IS_BUILTIN"
else
  die "Driver $DRIVER IS NOT configured as built-in"
fi

if [[ $DRIVER == "sdhci-acpi" ]]; then
  DRIVER="sdhci_acpi"
elif [[ $DRIVER == "pwm-lpss" ]] || [[ $DRIVER == "pwm-lpss-pci" ]] || [[ $DRIVER == "pwm-lpss-platform" ]]; then
  DRIVER="pwm"
elif [[ $DRIVER == "spi-pxa2xx-pci" ]] || [[ $DRIVER == "spi-pxa2xx-platform" ]]; then
  DRIVER="pxa2xx"
fi

# LOOK FOR LOG DRIVER MESSAGES
do_cmd "dmesg | grep $DRIVER"
