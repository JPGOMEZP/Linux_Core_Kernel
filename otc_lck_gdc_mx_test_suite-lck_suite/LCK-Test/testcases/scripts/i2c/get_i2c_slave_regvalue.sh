#!/bin/sh
#
# Copyright (C) 2011 Texas Instruments Incorporated - http://www.ti.com/
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

# Get I2C slave device register value for different platform
# By default, this script return a default value to testing
# If passing in slave_device name, this script will return the default
# value for this slave device
# Input: (optional)slave_device;
# Output: slave_dev_regvalue

source "common.sh"

############################### CLI Params ###################################
#if [ $# -lt 1 ]; then
#        echo "Error: Invalid Argument Count"
#        echo "Syntax: $0 [slave_device] "
#        exit 1
#fi
if [ "$#" -ge 1 -a -n "$1" ]; then
	SLAVE_DEVICE=$1
fi

############################ USER-DEFINED Params ##############################
# Try to avoid defining values here, instead see if possible
# to determine the value dynamically
case $ARCH in
esac
case $DRIVER in
esac
case $SOC in
esac
case $MACHINE in
        am17x-evm|da850-omapl138-evm)

                case $SLAVE_DEVICE in
                        *)
                                SLAVE_REGVAL=0x02
                        ;;
                esac
                ;;
		ecs|ECS)
				case $SLAVE_DEVICE in
						accel*|ACCEL*)
								SLAVE_REGVAL=0x0
						;;
						compass|COMPASS)
								SLAVE_REGVAL=0x01
						;;
						gyro*|GYRO*)
								SLAVE_REGVAL=0x0
						;;
						als|ALS)
								SLAVE_REGVAL=0x5a
						;;
						*)
								SLAVE_REGVAL=0x02
						;;
				esac
				;;
		anchor8|ANCHOR8)
				case $SLAVE_DEVICE in
						accel*|ACCEL*)
								SLAVE_REGVAL=0x0
						;;
						compass|COMPASS)
								SLAVE_REGVAL=0x01
						;;
						gyro*|GYRO*)
								SLAVE_REGVAL=0x0
						;;
						als|ALS)
								SLAVE_REGVAL=0x83
						;;
						*)
								SLAVE_REGVAL=0x02
						;;
				esac
				;;
		ecs2_8a|ECS2_8A)
				case $SLAVE_DEVICE in
						accel*|ACCEL*)
								SLAVE_REGVAL=0x0
						;;
						*)
								SLAVE_REGVAL=0x02
						;;
				esac
				;;
		ecs2_7b|ECS2_7B)
				case $SLAVE_DEVICE in
						accel*|ACCEL*)
								SLAVE_REGVAL=0x0
						;;
						*)
								SLAVE_REGVAL=0x02
						;;
				esac
				;;
		malata8|MALATA8)
				case $SLAVE_DEVICE in
						accel*|ACCEL*)
								SLAVE_REGVAL=0x08
						;;
						compass|COMPASS)
								SLAVE_REGVAL=
						;;
						gyro*|GYRO*)
								SLAVE_REGVAL=0x08
						;;
						als|ALS)
								SLAVE_REGVAL=
						;;
						*)
								SLAVE_REGVAL=0x02
						;;
				esac
				;;
		ecs2_10a|ECS2_10A)
				case $SLAVE_DEVICE in
						accel*|ACCEL*)
								SLAVE_REGVAL=0x0
						;;
						*)
								SLAVE_REGVAL=0x02
						;;
				esac
				;;
esac

: ${SLAVE_REGVAL:=0x55}
echo $SLAVE_REGVAL
