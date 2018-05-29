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
# Apr, 2016. Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#   - Initial draft.

############################ DESCRIPTION ######################################

# This script is executed by crontab at reboot time. It comments the tests
# already executed and run the remaining in order to complete WDT test suite.

############################# FUNCTIONS #######################################

############################ DO THE WORK ######################################

CUSER=$(whoami)
PASSWORD=linux

export thispath=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Is WDT test suite being executed?
IS_EXECUTED=`cat ${thispath}/wdt_test_suite_tracker`

if [ $IS_EXECUTED -eq 1 ]; then

  # What test scenario is being executed?
  TEST_SCENARIO=`cat ${thispath}/wdt_test_scenario_tracker`

  # How many reboots the platform has done?
  REBOOT=`cat ${thispath}/wdt_reboot_tracker`

  # WDT BAT is excuted
  if [ $TEST_SCENARIO == "wdt-bat-tests" ]; then

    # Reboot 1
    if [ $REBOOT -eq 1 ]; then
      sed -i 's/^WDT/#WDT/g' ${thispath}/../../../runtest/wdt/wdt-bat-tests
      sed -i 's/#WDT_FUNC_WATCHDOG_TEST/WDT_FUNC_WATCHDOG_TEST/g' ${thispath}/../../../runtest/wdt/wdt-bat-tests
      echo $PASSWORD | sudo -S ls &> /dev/null; sleep 3
      cd ${thispath}/../../../../ && echo $PASSWORD | sudo -S ./run_lck_test.sh -d wdt -t bat -k module

    # Reboot 2
    elif [ $REBOOT -eq 2 ]; then
      sed -i 's/^#WDT/WDT/g' ${thispath}/../../../runtest/wdt/wdt-bat-tests
      echo 0 > ${thispath}/wdt_test_suite_tracker
    fi

  # WDT functional test is executed
  elif [ $TEST_SCENARIO == "wdt-func-tests" ]; then

    # Reboot 1
    if [ $REBOOT -eq 1 ]; then
      sed -i 's/^WDT/#WDT/g' ${thispath}/../../../runtest/wdt/wdt-func-tests
      sed -i 's/#WDT_FUNC_WATCHDOG_MAGIC_CLOSE/WDT_FUNC_WATCHDOG_MAGIC_CLOSE/g' ${thispath}/../../../runtest/wdt/wdt-func-tests
      sed -i 's/#WDT_FUNC_WATCHDOG_TEST/WDT_FUNC_WATCHDOG_TEST/g' ${thispath}/../../../runtest/wdt/wdt-func-tests
      echo $PASSWORD | sudo -S ls &> /dev/null; sleep 3
      cd ${thispath}/../../../../ && echo $PASSWORD | sudo -S ./run_lck_test.sh -d wdt -t func -k module

    # Reboot 2
    elif [ $REBOOT -eq 2 ]; then
      sed -i 's/^WDT/#WDT/g' ${thispath}/../../../runtest/wdt/wdt-func-tests
      sed -i 's/#WDT_FUNC_HEARTBEAT_NOWAYOUT_0/WDT_FUNC_HEARTBEAT_NOWAYOUT_0/g' ${thispath}/../../../runtest/wdt/wdt-func-tests
      sed -i 's/#WDT_FUNC_HEARTBEAT_NOWAYOUT_1/WDT_FUNC_HEARTBEAT_NOWAYOUT_1/g' ${thispath}/../../../runtest/wdt/wdt-func-tests
      echo $PASSWORD | sudo -S ls &> /dev/null; sleep 3
      cd ${thispath}/../../../../ && echo $PASSWORD | sudo -S ./run_lck_test.sh -d wdt -t func -k module

    # Reboot 3
    elif [ $REBOOT -eq 3 ]; then
      sed -i 's/^#WDT/WDT/g' ${thispath}/../../../runtest/wdt/wdt-func-tests
      echo 0 > ${thispath}/wdt_test_suite_tracker
    fi

  # WDT full test is executed
  elif [ $TEST_SCENARIO == "wdt-full-tests" ]; then

    # Reboot 1
    if [ $REBOOT -eq 1 ]; then
      sed -i 's/^WDT/#WDT/g' ${thispath}/../../../runtest/wdt/wdt-full-tests
      sed -i 's/#WDT_FUNC_WATCHDOG_MAGIC_CLOSE/WDT_FUNC_WATCHDOG_MAGIC_CLOSE/g' ${thispath}/../../../runtest/wdt/wdt-full-tests
      sed -i 's/#WDT_FUNC_WATCHDOG_TEST/WDT_FUNC_WATCHDOG_TEST/g' ${thispath}/../../../runtest/wdt/wdt-full-tests
      echo $PASSWORD | sudo -S ls &> /dev/null; sleep 3
      cd ${thispath}/../../../../ && echo $PASSWORD | sudo -S ./run_lck_test.sh -d wdt -t full -k module

    # Reboot 2
    elif [ $REBOOT -eq 2 ]; then
      sed -i 's/^WDT/#WDT/g' ${thispath}/../../../runtest/wdt/wdt-full-tests
      sed -i 's/#WDT_FUNC_HEARTBEAT_NOWAYOUT_0/WDT_FUNC_HEARTBEAT_NOWAYOUT_0/g' ${thispath}/../../../runtest/wdt/wdt-full-tests
      sed -i 's/#WDT_FUNC_HEARTBEAT_NOWAYOUT_1/WDT_FUNC_HEARTBEAT_NOWAYOUT_1/g' ${thispath}/../../../runtest/wdt/wdt-full-tests
      echo $PASSWORD | sudo -S ls &> /dev/null; sleep 3
      cd ${thispath}/../../../../ && echo $PASSWORD | sudo -S ./run_lck_test.sh -d wdt -t full -k module

    # Reboot 3
    elif [ $REBOOT -eq 3 ]; then
      sed -i 's/^WDT/#WDT/g' ${thispath}/../../../runtest/wdt/wdt-full-tests
      sed -i 's/#WDT_STRESS_KEEPALIVE/WDT_STRESS_KEEPALIVE/g' ${thispath}/../../../runtest/wdt/wdt-full-tests
      sed -i 's/#WDT_STRESS_WRITE_LONG/WDT_STRESS_WRITE_LONG/g' ${thispath}/../../../runtest/wdt/wdt-full-tests
      echo $PASSWORD | sudo -S ls &> /dev/null; sleep 3
      cd ${thispath}/../../../../ && echo $PASSWORD | sudo -S ./run_lck_test.sh -d wdt -t full -k module

    # Reboot 4
    elif [ $REBOOT -eq 4 ]; then
      sed -i 's/^#WDT/WDT/g' ${thispath}/../../../runtest/wdt/wdt-full-tests
      echo 0 > ${thispath}/wdt_test_suite_tracker
    fi
  fi
else
  echo "WDT test suite is not being executed"
fi
