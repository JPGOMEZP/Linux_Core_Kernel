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
#     - modified script to align it to LCK standard.
# Mar, 2016
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Updated script to remove unncessary and duplicated lines.
# Apr, 2016
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Added paths for caps lock, num lock and scroll lock to export them for
#       EC tests.
#     - Get platform name in order to set the correct paths for EC tests,
#       since there are some differences between platforms.
# May, 2016
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Modified the way to get CAPS, NUM and SCROLL lock keys/leds for EC
#       dinamically
# Jun, 2016
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Added USB paths
#     - Added SDHCI paths
#     - Added PWM paths
# Juan, 2016
#    Juan Pablo Gomez <juan.p.gomez@intel.com>
#     - Added LPC  paths
# Jul, 2016
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Added SPI paths
# Sep. 2016
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Added $SPI_SCRIPTS path
#     - Deleted 'export LOGS' variable from this script
#     - Added '$USB_SCRIPTS' path to export it
# Octi, 2016
#   Juan Pablo Gomez <juan.p.gomez@intel.com>
#     - Added Thermal paths
#
############################# DESCRIPTION #####################################

# This script exports both paths and variables for a corresponding driver.

############################# FUNCTIONS #######################################

############################ DO THE WORK ######################################

DRIVER=$1

export PATH="$PATH:$PWD"

# EXPORT COMMON PATHS
export PATH="$PATH:$PWD/LCK-Test/testcases/scripts/common"
export PATH="$PATH:$PWD/LCK-Test/testcases/scripts/$DRIVER"
export RUNTEST="$PWD/LCK-Test/runtest/$DRIVER"
export WHAT_DRIVERS="$PWD/what_drivers"
export TEST_SUITE="$PWD/test_suite"

# EXPORT PATHS AND VARIABLES FOR WDT
if [ $DRIVER == "wdt" ]; then
  export PATH="$PATH:$PWD/LCK-Test/testcases/wdt_test_suite"
  export WDT_SCRIPTS="$PWD/LCK-Test/testcases/scripts/wdt"
  export WDAT_DIR="/sys/bus/platform/drivers/wdat_wdt"
  export WDT_SUITE="$PWD/LCK-Test/testcases/wdt_test_suite"
  export wdat_wdt="wdat_wdt"
  export iTCO_wdt="iTCO_wdt"
  export i2c_smbus="i2c-smbus"
  export i2c_i801="i2c-i801"

# EXPORT PATHS AND VARIABLES FOR SATA
elif [ $DRIVER == "sata" ]; then
  export PATH="$PATH:$PWD/LCK-Test/testcases/filesystem_test_suite"
  export AHCI_DIR="/sys/bus/pci/drivers/ahci"
  export SATA_SCRIPTS="$PWD/LCK-Test/testcases/scripts/sata"
  export TEST_DIR="$PWD/LCK-Test/testcases/scripts/sata/test_dir"
  export TEST_MNT_DIR_1="$TEST_DIR/mnt_dev_1"
  export TEST_MNT_DIR_2="$TEST_DIR/mnt_dev_2"
  export TEST_TMP_DIR="$TEST_DIR/tmp"

# EXPORT PATHS AND VARIABLES FOR PCIe
elif [ $DRIVER == "pcie" ]; then
  export PCI_DIR="/sys/bus/pci/drivers/pcieport"
  export PATH="$PATH:$PWD/LCK-Test/testcases/scripts/sata"
  export PATH="$PATH:$PWD/LCK-Test/testcases/filesystem_test_suite"
  export AHCI_DIR="/sys/bus/pci/drivers/ahci"
  export TEST_DIR="$PWD/LCK-Test/testcases/scripts/sata/test_dir"
  export TEST_MNT_DIR_1="$TEST_DIR/mnt_dev_1"
  export TEST_MNT_DIR_2="$TEST_DIR/mnt_dev_2"
  export TEST_TMP_DIR="$TEST_DIR/tmp"

# EXPORT PATHS AND VARIABLES FOR LPC
elif [ $DRIVER == "lpc" ]; then
  export LPC_PSMOUSE_DIR="/sys/bus/serio/drivers/psmouse"
  export LPC_ATKBD_DIR="/sys/bus/serio/drivers/atkbd"

# EXPORT PATHS AND VARIABLES FOR EC
elif [ $DRIVER == "ec" ]; then
  export EC_DIR="/sys/bus/acpi/drivers/ec"
  export LID_BUTTON="/proc/acpi/button/lid/LID0/state"

  S_CAPS_DIR=`ls -l /sys/class/leds/ | grep caps | grep serio | awk -F"->" '{print $1}' | awk '{print $9}'`
  P_CAPS_DIR=`ls -l /sys/class/leds/ | grep caps | grep pci | awk -F"->" '{print $1}' | awk '{print $9}'`
  S_NUM_DIR=`ls -l /sys/class/leds/ | grep num | grep serio | awk -F"->" '{print $1}' | awk '{print $9}'`
  P_NUM_DIR=`ls -l /sys/class/leds/ | grep num | grep pci | awk -F"->" '{print $1}' | awk '{print $9}'`
  S_SCROLL_DIR=`ls -l /sys/class/leds/ | grep scroll | grep serio | awk -F"->" '{print $1}' | awk '{print $9}'`
  P_SCROLL_DIR=`ls -l /sys/class/leds/ | grep scroll | grep pci | awk -F"->" '{print $1}' | awk '{print $9}'`

  export SER_CAPS_LOCK_DIR="/sys/class/leds/${S_CAPS_DIR}"
  export PCI_CAPS_LOCK_DIR="/sys/class/leds/${P_CAPS_DIR}"
  export SER_NUM_LOCK_DIR="/sys/class/leds/${S_NUM_DIR}"
  export PCI_NUM_LOCK_DIR="/sys/class/leds/${P_NUM_DIR}"
  export SER_SCROLL_LOCK_DIR="/sys/class/leds/${S_SCROLL_DIR}"
  export PCI_SCROLL_LOCK_DIR="/sys/class/leds/${P_SCROLL_DIR}"

# EXPORT PATHS AND VARIABLES FOR MEI
elif [ $DRIVER == "mei" ]; then
  export PATH="$PATH:$PWD/LCK-Test/testcases/scripts/mei/mei"
  export MEI_DIR="/sys/bus/pci/drivers/mei_me"

# EXPORT PATH AND VARIABLES FOR RTC
elif [ $DRIVER == "rtc" ]; then
  export PROC_RTC="/proc/driver/rtc"
  export SYS_RTC="/sys/class/rtc/rtc0"
  export ALARM="/sys/class/rtc/rtc0/wakealarm"

# EXPORT PATH AND VARIABLES FOR USB
elif [ $DRIVER == "usb" ]; then
  export USB_SCRIPTS="$PWD/LCK-Test/testcases/scripts/usb"
  export MODULE_PATH="/sys/module"
  export USB_PATH="/sys/bus/usb/devices"
  export DEVICE_PATH="/sys/kernel/debug/usb/devices"
  export PATH="$PATH:$PWD/LCK-Test/testcases/scripts/sata"
  export PATH="$PATH:$PWD/LCK-Test/testcases/filesystem_test_suite"
  export AHCI_DIR="/sys/bus/pci/drivers/ahci"
  export TEST_DIR="$PWD/LCK-Test/testcases/scripts/sata/test_dir"
  export TEST_MNT_DIR_1="$TEST_DIR/mnt_dev_1"
  export TEST_MNT_DIR_2="$TEST_DIR/mnt_dev_2"
  export TEST_TMP_DIR="$TEST_DIR/tmp"

# EXPORT PATH AND VARIABLES FOR SDHCI
elif [ $DRIVER == "sdhci" ]; then
  export MMC_PATH="/sys/bus/mmc/drivers/mmcblk"
  export DEBUGFS_MNT="/sys/kernel/debug"
  export PATH="$PATH:$PWD/LCK-Test/testcases/scripts/sata"
  export TEST_DIR="$PWD/LCK-Test/testcases/scripts/sata/test_dir"
  export PATH="$PATH:$PWD/LCK-Test/testcases/filesystem_test_suite"
  export TEST_MNT_DIR_1="$TEST_DIR/mnt_dev_1"
  export TEST_MNT_DIR_2="$TEST_DIR/mnt_dev_2"
  export TEST_TMP_DIR="$TEST_DIR/tmp"

# EXPORT PATH AND VARIABLES FOR PWM
elif [ $DRIVER == "pwm" ]; then
  export PWM_DEVICE="/sys/class/pwm"
  export PWM_PCI="/sys/bus/pci/drivers"
  export PWM_PLATFORM="/sys/bus/platform/drivers"

# EXPORT PATH AND VARIABLES FOR SPI
elif [ $DRIVER == "spi" ]; then
  export SPI_SCRIPTS="$PWD/LCK-Test/testcases/scripts/spi"
  export SPI_DRIVERS="/sys/bus/platform/drivers/pxa2xx-spi"
  export SPI_MASTER="/sys/class/spi_master"

elif [ $DRIVER == "ith" ]; then
  export ITH_SCRIPTS="$PWD/LCK-Test/testcases/scripts/ith"

# EXPORT PATH AND VARIABLES FOR THERMAL
elif [ $DRIVER == "thermal" ]; then
  export THERMAL_DIR="/sys/bus/acpi/drivers/thermal"
fi
