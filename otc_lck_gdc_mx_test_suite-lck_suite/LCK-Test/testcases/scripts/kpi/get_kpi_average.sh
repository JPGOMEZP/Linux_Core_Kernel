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

# This script read KPI files and get its average.

############################ FUNCTIONS ########################################

# PARSE THE FILE
get_driver_kpi() {

  linea=$1
  driver=$2
  initcall=$3

  DRIVER_BOOT=$(echo $linea | grep "$driver" | grep "$initcall" | awk '{print $2}' | sed 's/,//')
  if [ ! -z ${DRIVER_BOOT} ]; then
    boot_sum=$(echo $boot_sum + $DRIVER_BOOT | bc)
  fi

  DRIVER_SUSPEND=$(echo $linea | grep "$driver" | grep "suspend" | awk '{print $2}' | sed 's/,//')
  if [ ! -z ${DRIVER_SUSPEND} ]; then
    suspend_sum=$(echo $suspend_sum + $DRIVER_SUSPEND | bc)
  fi

  DRIVER_RESUME=$(echo $linea | grep "$driver" | grep "resume" | awk '{print $2}' | sed 's/,//')
  if [ ! -z ${DRIVER_RESUME} ]; then
    resume_sum=$(echo $resume_sum + $DRIVER_RESUME | bc)
  fi

}


print_kpi() {

  component=$1
  kpi_boot=$2
  kpi_suspend=$3
  kpi_resume=$4

  printf "%-13s boot\t$kpi_boot\n" "$component" >> ${HOME}/kpi_results
  printf "%-13s suspend\t$kpi_suspend\n" "$component" >> ${HOME}/kpi_results
  printf "%-13s resume\t$kpi_resume\n" "$component" >> ${HOME}/kpi_results

  clear_var

}

clear_var() {

  boot_sum=0
  suspend_sum=0
  resume_sum=0
  kpi_boot=0
  kpi_suspend=0
  kpi_resume=0
}

############################ DO THE WORK ######################################

FILE=$1

if [ -a "${HOME}/kpi_results" ]; then
  echo > ${HOME}/kpi_results
fi

declare -a DRIVERS=('LPC' 'MEI' 'PCIe' 'PWM_PCI' 'PWM_PLATFORM' 'RTC' 'SATA' 'SDHCI' 'USB_STORAGE' 'EHCI' 'XHCI' 'WDT' 'WDAT')
declare -a INITCALL=('lpc_ich' 'mei_me' 'pcie_portdrv_init' 'pwm_lpss_driver_pci_init' 'pwm_lpss_driver_platform_init' 'add_rtc_cmos' 'ahci_pci_driver_init' 'sdhci_driver_init' 'usb_storage_driver'
		     'ehci_hcd_init' 'xhci_hcd_init' 'iTCO_wdt_init' 'wdat_wdt_driver_init')
j=0

clear_var

if [ -a "$FILE" ]; then
  echo   "===============================" >> ${HOME}/kpi_results
  for i in ${DRIVERS[@]}; do
    while read line
    do
      get_driver_kpi "$line" "$i" "${INITCALL[$j]}"
    done < "$FILE"
    kpi_boot=$(echo "scale =3; ${boot_sum}/5.00" | bc)
    kpi_suspend=$(echo "scale =3; ${suspend_sum}/5.00" | bc)
    kpi_resume=$(echo "scale =3; ${resume_sum}/5.00" | bc)
    print_kpi "$i" "$kpi_boot" "$kpi_suspend" "$kpi_resume"
    echo   "-------------------------------" >> ${HOME}/kpi_results
    j=$(($j + 1))
  done
fi
