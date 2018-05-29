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
# Sep, 2016. Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#   - Initial draft.

############################ DESCRIPTION ######################################

# This script modify driver list in 'platform/<platform>'

############################# FUNCTIONS #######################################

############################ DO THE WORK ######################################

source "common.sh"

export thispath=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# GET PLATFORM IN USE
plataform=$(get_platform)

# MODIFY DRIVER LIST
sed -i 's/^sdhci/#sdhci/g' ${thispath}/../../../../platforms/${plataform}
sed -i 's/^spi/#spi/g' ${thispath}/../../../../platforms/${plataform}
sed -i 's/^#usb/usb/g' ${thispath}/../../../../platforms/${plataform}
sed -i 's/^#wdt/wdt/g' ${thispath}/../../../../platforms/${plataform}
