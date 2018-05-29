#!/bin/bash

###############################################################################
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
# Desciption: This cript checks if drivers needed are configured as module or
#             built in, depending on what kind of kernel will be compiled.
#
# Use: ./check_config_driver.sh m - To check drivers as module
#      ./check_config_driver.sh y - To check drivers as built in
#
###############################################################################

############################ CONTRIBUTORS #####################################

# Author: Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#
# Jan, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Initial draft.
# Jul, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Updated script. Added SPI Kernel configs.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Updated script. Added Kernel configs for all components.
# Dec, 2016. Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Added 'CONFIG_WDAT_WDT' to check.

############################ DESCRIPTION ######################################

# This script checks Kernel configs for different drivers.

############################# FUNCTIONS #######################################

############################ DO THE WORK ######################################

if [ $# -ne 1 ]; then
  echo "$0: must supply a parameter:"
  echo "./check_config_driver.sh m - To check drivers as module"
  echo "./check_config_driver.sh y - To check drivers as built in"
fi

m_or_y=$1

declare -a COMMON_DRIVERS=('CONFIG_USB_EHCI_HCD=y' 'CONFIG_USB_XHCI_HCD=y'
                           'CONFIG_USB_STORAGE=y' 'CONFIG_BLK_DEV_SD=y'
                           'CONFIG_RTC_HCTOSYS=y' 'CONFIG_THERMAL=y' 'CONFIG_ACPI_THERMAL=y'
			   'CONFIG_GPIOLIB=y' 'CONFIG_GPIO_ACPI=y' 'CONFIG_GPIO_SYSFS=y')

declare -a ALL_DRIVERS=('CONFIG_LPC_ICH' 'CONFIG_LPC_SCH' 'CONFIG_KEYBOARD_ATKBD' 'CONFIG_MOUSE_PS2' 'CONFIG_SERIO_I8042' 'CONFIG_INTEL_MEI' 'CONFIG_INTEL_MEI_TXE' 'CONFIG_INTEL_MEI_ME' 'CONFIG_PWM_LPSS' 'CONFIG_PWM_LPSS_PCI' 'CONFIG_PWM_LPSS_PLATFORM' 'CONFIG_PWM_PCA9685' 'CONFIG_BACKLIGHT_PWM' 'CONFIG_REGULATOR_PWM' 'CONFIG_RTC_DRV_CMOS' 'CONFIG_SATA_AHCI' 'CONFIG_MMC_SDHCI' 'CONFIG_MMC_SDHCI_ACPI' 'CONFIG_MMC_SDHCI_PCI' 'CONFIG_SPI_PXA2XX_PCI' 'CONFIG_SPI_PXA2XX' 'CONFIG_WDAT_WDT' 'CONFIG_ITCO_WDT' 'CONFIG_I2C_SMBUS' 'CONFIG_I2C_I801' 'CONFIG_I2C_DESIGNWARE_PLATFORM' 'CONFIG_I2C_CHARDEV')

for i in ${COMMON_DRIVERS[@]}
do
  DRIVER=`grep "$i" .config`
  if [ ! -z $DRIVER ]; then
    echo "$i is correct"
  else
    echo "Change $i before compile"
  fi
done

for i in ${ALL_DRIVERS[@]}
do
  DRIVER=`grep "$i=$m_or_y" .config`
  if [ ! -z $DRIVER ]; then
    echo "$i is correct"
  else
    echo "Change $i before compile"
  fi
done
