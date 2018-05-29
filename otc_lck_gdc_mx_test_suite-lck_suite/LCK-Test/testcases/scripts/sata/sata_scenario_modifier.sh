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
# Jul, 2016. Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#   - Initial draft.
# Sep, 2016. Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#   - Updated scriot to modify driver lists un 'platform/<platform>' file

############################ DESCRIPTION ######################################

# This script is executed by crontab at reboot time. It comments the tests
# already executed and run the remaining in order to complete SATA test suite.

############################# FUNCTIONS #######################################

############################ DO THE WORK ######################################

source "common.sh"

CUSER=$(whoami)
PASSWORD=linux

export thispath=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

plataform=$(get_platform)

# Is SATA test suite being executed?
IS_EXECUTED=`cat ${thispath}/sata_test_suite_tracker`

if [ $IS_EXECUTED -eq 1 ]; then

  # What test scenario is being executed?
  TEST_SCENARIO=`cat ${thispath}/sata_test_scenario_tracker`

  # How many reboots the platform has done?
  REBOOT=`cat ${thispath}/sata_reboot_tracker`

  # SATA BAT is excuted
  if [ $TEST_SCENARIO == "sata-bat-tests" ]; then

    # Reboot 1
    if [ $REBOOT -eq 0 ]; then

      sed -i 's/^SATA/#SATA/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_ENUMERATION_DEVICE/SATA_FUNC_ENUMERATION_DEVICE/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_AHCI_SPEC/SATA_FUNC_AHCI_SPEC/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_GEN3_SPEC/SATA_FUNC_GEN3_SPEC/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_NCQ_SPEC/SATA_FUNC_NCQ_SPEC/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_HOTPLUG_SPEC/SATA_FUNC_HOTPLUG_SPEC/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_POWER_MANAGEMENT_D0/SATA_FUNC_POWER_MANAGEMENT_D0/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_EXT2_DD_RW_10M/SATA_FUNC_EXT2_DD_RW_10M/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_EXT3_DD_RW_10M/SATA_FUNC_EXT3_DD_RW_10M/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_EXT4_DD_RW_10M/SATA_FUNC_EXT4_DD_RW_10M/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_VFAT_DD_RW_10M/SATA_FUNC_VFAT_DD_RW_10M/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_EXT2_DD_RW_SSD1_TO_SSD2_10M/SATA_FUNC_EXT2_DD_RW_SSD1_TO_SSD2_10M/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_EXT3_DD_RW_SSD1_TO_SSD2_10M/SATA_FUNC_EXT3_DD_RW_SSD1_TO_SSD2_10M/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_EXT4_DD_RW_SSD1_TO_SSD2_10M/SATA_FUNC_EXT4_DD_RW_SSD1_TO_SSD2_10M/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_VFAT_DD_RW_SSD1_TO_SSD2_10M/SATA_FUNC_VFAT_DD_RW_SSD1_TO_SSD2_10M/g' ${thispath}/../../../runtest/sata/sata-bat-tests

      sed -i 's/^/#/g' ${thispath}/../../../../platforms/${plataform}
      sed -i 's/^#sata/sata/g' ${thispath}/../../../../platforms/${plataform}

    # Reboot 2
    elif [ $REBOOT -eq 1 ]; then
      sed -i 's/^SATA/#SATA/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_LOAD_DRIVER_AS_MODULE/SATA_FUNC_LOAD_DRIVER_AS_MODULE/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_UNLOAD_DRIVER_AS_MODULE/SATA_FUNC_UNLOAD_DRIVER_AS_MODULE/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_BIND_UNBIND_DRIVER/SATA_FUNC_BIND_UNBIND_DRIVER/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_EXT2_DD_RW_HDD_10M/SATA_FUNC_EXT2_DD_RW_HDD_10M/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_EXT3_DD_RW_HDD_10M/SATA_FUNC_EXT3_DD_RW_HDD_10M/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_EXT4_DD_RW_HDD_10M/SATA_FUNC_EXT4_DD_RW_HDD_10M/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_VFAT_DD_RW_HDD_10M/SATA_FUNC_VFAT_DD_RW_HDD_10M/g' ${thispath}/../../../runtest/sata/sata-bat-tests

    elif [ $REBOOT -eq 2 ]; then
      sed -i 's/^SATA/#SATA/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      sed -i 's/#SATA_FUNC_CDROM_READ_SUPPORT/SATA_FUNC_CDROM_READ_SUPPORT/g' ${thispath}/../../../runtest/sata/sata-bat-tests

    elif [ $REBOOT -eq 3 ]; then
      sed -i 's/#SATA/SATA/g' ${thispath}/../../../runtest/sata/sata-bat-tests
      echo 0 > ${thispath}/sata_test_suite_tracker
      echo 0 > ${thispath}/sata_reboot_tracker
      sed -i 's/sata/#sata/g' ${thispath}/../../../../platforms/${plataform}
      sed -i 's/#sdhci/sdhci/g' ${thispath}/../../../../platforms/${plataform}
      sed -i 's/#spi/spi/g' ${thispath}/../../../../platforms/${plataform}
    fi

  # SATA FUNC is excuted
  elif [ $TEST_SCENARIO == "sata-func-tests" ]; then

    # Reboot 1
    if [ $REBOOT -eq 0 ]; then
      sed -i 's/^SATA/#SATA/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_ENUMERATION_DEVICE/SATA_FUNC_ENUMERATION_DEVICE/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_AHCI_SPEC/SATA_FUNC_AHCI_SPEC/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_GEN3_SPEC/SATA_FUNC_GEN3_SPEC/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_NCQ_SPEC/SATA_FUNC_NCQ_SPEC/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_HOTPLUG_SPEC/SATA_FUNC_HOTPLUG_SPEC/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_POWER_MANAGEMENT_D0/SATA_FUNC_POWER_MANAGEMENT_D0/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_EXT2_DD_RW_10M/SATA_FUNC_EXT2_DD_RW_10M/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_EXT3_DD_RW_10M/SATA_FUNC_EXT3_DD_RW_10M/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_EXT4_DD_RW_10M/SATA_FUNC_EXT4_DD_RW_10M/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_VFAT_DD_RW_10M/SATA_FUNC_VFAT_DD_RW_10M/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_EXT2_DD_RW_SSD1_TO_SSD2_10M/SATA_FUNC_EXT2_DD_RW_SSD1_TO_SSD2_10M/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_EXT3_DD_RW_SSD1_TO_SSD2_10M/SATA_FUNC_EXT3_DD_RW_SSD1_TO_SSD2_10M/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_EXT4_DD_RW_SSD1_TO_SSD2_10M/SATA_FUNC_EXT4_DD_RW_SSD1_TO_SSD2_10M/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_VFAT_DD_RW_SSD1_TO_SSD2_10M/SATA_FUNC_VFAT_DD_RW_SSD1_TO_SSD2_10M/g' ${thispath}/../../../runtest/sata/sata-func-tests

    # Reboot 2
    elif [ $REBOOT -eq 1 ]; then
      sed -i 's/^SATA/#SATA/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_LOAD_DRIVER_AS_MODULE/SATA_FUNC_LOAD_DRIVER_AS_MODULE/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_UNLOAD_DRIVER_AS_MODULE/SATA_FUNC_UNLOAD_DRIVER_AS_MODULE/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_BIND_UNBIND_DRIVER/SATA_FUNC_BIND_UNBIND_DRIVER/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_EXT2_DD_RW_HDD_10M/SATA_FUNC_EXT2_DD_RW_HDD_10M/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_EXT3_DD_RW_HDD_10M/SATA_FUNC_EXT3_DD_RW_HDD_10M/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_EXT4_DD_RW_HDD_10M/SATA_FUNC_EXT4_DD_RW_HDD_10M/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_VFAT_DD_RW_HDD_10M/SATA_FUNC_VFAT_DD_RW_HDD_10M/g' ${thispath}/../../../runtest/sata/sata-func-tests

    elif [ $REBOOT -eq 2 ]; then
      sed -i 's/^SATA/#SATA/g' ${thispath}/../../../runtest/sata/sata-func-tests
      sed -i 's/#SATA_FUNC_CDROM_READ_SUPPORT/SATA_FUNC_CDROM_READ_SUPPORT/g' ${thispath}/../../../runtest/sata/sata-func-tests

    elif [ $REBOOT -eq 3 ]; then
      sed -i 's/#SATA/SATA/g' ${thispath}/../../../runtest/sata/sata-func-tests
      echo 0 > ${thispath}/sata_test_suite_tracker
      echo 0 > ${thispath}/sata_reboot_tracker
    fi

  # SATA full test is executed
  elif [ $TEST_SCENARIO == "sata-full-tests" ]; then

    # Reboot 1
    if [ $REBOOT -eq 0 ]; then
      sed -i 's/^SATA/#SATA/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_ENUMERATION_DEVICE/SATA_FUNC_ENUMERATION_DEVICE/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_AHCI_SPEC/SATA_FUNC_AHCI_SPEC/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_GEN3_SPEC/SATA_FUNC_GEN3_SPEC/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_NCQ_SPEC/SATA_FUNC_NCQ_SPEC/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_HOTPLUG_SPEC/SATA_FUNC_HOTPLUG_SPEC/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_POWER_MANAGEMENT_D0/SATA_FUNC_POWER_MANAGEMENT_D0/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_EXT2_DD_RW_10M/SATA_FUNC_EXT2_DD_RW_10M/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_EXT3_DD_RW_10M/SATA_FUNC_EXT3_DD_RW_10M/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_EXT4_DD_RW_10M/SATA_FUNC_EXT4_DD_RW_10M/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_VFAT_DD_RW_10M/SATA_FUNC_VFAT_DD_RW_10M/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_EXT2_DD_RW_SSD1_TO_SSD2_10M/SATA_FUNC_EXT2_DD_RW_SSD1_TO_SSD2_10M/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_EXT3_DD_RW_SSD1_TO_SSD2_10M/SATA_FUNC_EXT3_DD_RW_SSD1_TO_SSD2_10M/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_EXT4_DD_RW_SSD1_TO_SSD2_10M/SATA_FUNC_EXT4_DD_RW_SSD1_TO_SSD2_10M/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_VFAT_DD_RW_SSD1_TO_SSD2_10M/SATA_FUNC_VFAT_DD_RW_SSD1_TO_SSD2_10M/g' ${thispath}/../../../runtest/sata/sata-full-tests

    # Reboot 2
    elif [ $REBOOT -eq 1 ]; then
      sed -i 's/^SATA/#SATA/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_LOAD_DRIVER_AS_MODULE/SATA_FUNC_LOAD_DRIVER_AS_MODULE/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_UNLOAD_DRIVER_AS_MODULE/SATA_FUNC_UNLOAD_DRIVER_AS_MODULE/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_BIND_UNBIND_DRIVER/SATA_FUNC_BIND_UNBIND_DRIVER/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_EXT2_DD_RW_HDD_10M/SATA_FUNC_EXT2_DD_RW_HDD_10M/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_EXT3_DD_RW_HDD_10M/SATA_FUNC_EXT3_DD_RW_HDD_10M/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_EXT4_DD_RW_HDD_10M/SATA_FUNC_EXT4_DD_RW_HDD_10M/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_VFAT_DD_RW_HDD_10M/SATA_FUNC_VFAT_DD_RW_HDD_10M/g' ${thispath}/../../../runtest/sata/sata-full-tests      

    # Reboot 3
    elif [ $REBOOT -eq 2 ]; then
      sed -i 's/^SATA/#SATA/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_FUNC_CDROM_READ_SUPPORT/SATA_FUNC_CDROM_READ_SUPPORT/g' ${thispath}/../../../runtest/sata/sata-full-tests

    # Reboot 4
    elif [ $REBOOT -eq 3 ]; then
      sed -i 's/^SATA/#SATA/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_PERF_EXT2_100M/SATA_PERF_EXT2_100M/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_PERF_EXT3_100M/SATA_PERF_EXT3_100M/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_PERF_EXT4_100M/SATA_PERF_EXT4_100M/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_PERF_VFAT_100M/SATA_PERF_VFAT_100M/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_STRESS_EXT2_DD_RW_100M/SATA_STRESS_EXT2_DD_RW_100M/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_STRESS_EXT3_DD_RW_100M/SATA_STRESS_EXT3_DD_RW_100M/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_STRESS_EXT4_DD_RW_100M/SATA_STRESS_EXT4_DD_RW_100M/g' ${thispath}/../../../runtest/sata/sata-full-tests
      sed -i 's/#SATA_STRESS_VFAT_DD_RW_100M/SATA_STRESS_VFAT_DD_RW_100M/g' ${thispath}/../../../runtest/sata/sata-full-tests

    elif [ $REBOOT -eq 4 ]; then
      sed -i 's/^#SATA/SATA/g' ${thispath}/../../../runtest/sata/sata-full-tests      
      echo 0 > ${thispath}/sata_test_suite_tracker
      echo 0 > ${thispath}/sata_reboot_tracker

    fi
  fi
else
  echo "SATA test suite is not being executed"
fi
