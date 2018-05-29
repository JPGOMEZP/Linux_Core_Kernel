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

# Author: Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#
# Jan, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Initial draft.
#     - Modify script to handle different components since they have different
#       driver paths and driver IDs.
# Jul, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Updated script to bind/unbind SPI driver to its controller.
#
# Oct, 2016.
#   Juan Pablo Gomez <juan.p.gomez@intel.com>
#     - Updated script to bind/unbind Thermal driver
#
#
############################ DESCRIPTION ######################################

# This script gets the driver directory and driver ID, so it bind/unbind the
# driver to the controller.
#
#   - bind_unbind(): receives driver directory and ID to perform driver
#     bind/unbind to the controller.

############################# FUNCTIONS #######################################

bind_unbind()
{
  DRIVER=$1
  DIR=$2
  ID=$3

  # CHECK DRIVER AND CONTROLLER ARE BOUND
  do_cmd ls -l $DIR
  if [ $? -eq 0 ]; then
    test_print_trc "$DRIVER Driver and controller are bound"
  else
    die "$DRIVER Driver is not loaded or controller is not bound"
  fi

  do_cmd cd $DIR

  # UNBIND DRIVER AND CONTROLLER
  echo $ID > unbind
  if [ $? -eq 0 ]; then
    test_print_trc "$DRIVER Driver and controller were unbind"
  else
    die "$DRIVER Driver and controller cannot unbind"
  fi

  do_cmd ls -l

  # BIND DRIVER AND CONTROLLER
  echo $ID > bind
  if [ $? -eq 0 ]; then
    test_print_trc "$DRIVER Driver and controller were bind"
  else
    die "$DRIVER Driver and controller cannot bind"
  fi

  do_cmd ls -l

  do_cmd cd -
}

############################ DO THE WORK ######################################

source "common.sh"
source "ith_common.sh"

DRIVER=$1

# LOAD DRIVER
if [ $DRIVER != "ec" -a $DRIVER != "sdhci" -a $DRIVER != "spi" ] ; then
  do_cmd load_unload_module.sh -l -d "$DRIVER"
fi

# SET DIRECTORY AND DRIVER ID
if [ $DRIVER == "ahci" ]; then
  DRIVER_DIR=$AHCI_DIR
  SATA_ID=`lspci | grep SATA | cut -d' ' -f1`
  DRIVER_ID=`ls $AHCI_DIR | grep $SATA_ID`
elif [ $DRIVER == "wdat_wdt" ]; then
  DRIVER_DIR=$WDAT_DIR
  DRIVER_ID=$wdat_wdt
elif [ $DRIVER == "ec" ]; then
  DRIVER_DIR=$EC_DIR
  DRIVER_ID=`ls $EC_DIR | grep -i "PNP"`
elif [ $DRIVER == "mei-me" ]; then
  DRIVER_DIR=$MEI_DIR
  DRIVER_ID=`ls $MEI_DIR | grep "0000"`
elif [ $DRIVER == "atkbd" ]; then
  DRIVER_DIR=$LPC_ATKBD_DIR
  DRIVER_ID=`ls $LPC_ATKBD_DIR | grep "serio"`
elif [ $DRIVER == "psmouse" ]; then
  DRIVER_DIR=$LPC_PSMOUSE_DIR
  DRIVER_ID=`ls $LPC_PSMOUSE_DIR | grep "serio"`
elif [ $DRIVER == "sdhci" ]; then
  DRIVER_DIR=$MMC_PATH
  DRIVER_ID=`ls $MMC_PATH | grep mmc`

elif [ $DRIVER == "thermal" ]; then
  DRIVER_DIR=$THERMAL_DIR
  DRIVER_ID=`ls $THERMAL_DIR | grep LNXTHERM`


elif [ $DRIVER == "spi" ]; then
  DRIVER_DIR=$SPI_DRIVERS
  DRIVER_ID=`ls $SPI_DRIVERS | grep pxa2xx`
fi

# BIND/UNBIND DRIVER
if [ $DRIVER == "spi" ]; then
  for i in ${DRIVER_ID[@]}; do
    bind_unbind $DRIVER $DRIVER_DIR $i
  done
else
  bind_unbind $DRIVER $DRIVER_DIR $DRIVER_ID
fi

# UNLOAD DRIVER
if [ $DRIVER != "ec" -a $DRIVER != "sdhci" -a $DRIVER != "spi" -a $DRIVER != "thermal" ]; then
  do_cmd load_unload_module.sh -u -d "$DRIVER"
fi
