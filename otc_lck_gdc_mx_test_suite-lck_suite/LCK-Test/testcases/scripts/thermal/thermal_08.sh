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
###############################################################################

# Copyright (C) 2015, Intel - http://www.intel.com
# @Author   Luis Rivas <luis.miguel.rivas.zepeda@intel.com>
# @desc     Hwmon sysfs I/F extension is available under /sys/class/hwmon
#           if how is compiled in or build as a module. It only checks devices
#           under /sys/devices/virtual/hwmon
# @returns  0 if the execution was finished succesfully, else 1
# @history  2015-02-24: First Version (Luis Rivas)

source functions.sh
source thermal_functions.sh

############################# Functions #######################################
check_hwmon_sysfs() {
    local hwmon_path=$HWMON_PATH/$1
    local inputs=$(ls $hwmon_path | grep -E 'temp[0-9]+_input')
    local criticals=$(ls $hwmon_path | grep -E 'temp[0-9]+_critical')
    check_file "name" $hwmon_path || return 1
    check "Temp inputs exists on $hwmon_path" "test" $inputs
    return 0
}

for_each_hwmon() {
    local func=$1
    shift 1
    local hwmons=$(ls $HWMON_PATH | grep -E 'hwmon[0-9]+')

    if [ -z "$hwmons" ]; then
        log_end "fail"
        return 1
    fi

    INC=0
    for hwmon in $hwmons; do
	    $func $hwmon $@
        if [ $? -ne 0 ]; then
            log_end "fail"
            return 1
        fi
    done
    return 0
}

############################ Script Variables ##################################
# Define default valus if possible
HWMON_PATH="/sys/devices/virtual/hwmon"

########################### REUSABLE TEST LOGIC ###############################
# DO NOT HARDCODE any value. If you need to use a specific value for your setup
# use user-defined Params section above.
for_each_hwmon check_hwmon_sysfs || exit 1
