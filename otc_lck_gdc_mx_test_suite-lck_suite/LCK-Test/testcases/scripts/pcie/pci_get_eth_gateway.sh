#!/bin/bash

############################################################################### 
#
# Copyright (C) 2011 Texas Instruments Incorporated - http://www.ti.com/
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

# Author: LTP-DDT
#
# Jan, 2016.
#   Juan Pablo Gomez (juan.p.gomez@intel.com)
#     - Ported from LTP-DDT projecto to LCK project.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Modified script in order to align it to LCK repository standard.

############################ DESCRIPTION ######################################

# This script retuns gateway for a given ethernet interface.

############################# FUNCTIONS #######################################

usage()
{
	echo "get_eth_gateway.sh -i <eth interface (i.e. eth0)>"
	echo "Returns the Gateway's IP address for given interface"
	exit 1
}

############################ DO THE WORK ######################################

source "common.sh"

while getopts :i:h arg
do case $arg in
  i)  IFACE="$OPTARG";;
  h)  usage;;
  :)  die "$0: Must supply an argument to -$OPTARG.";;
  \?) die "Invalid Option -$OPTARG ";;
esac
done

# GET GATEWAY
GATEWAY=`route -n | awk -v pat="UG.+${IFACE}" '$0 ~ pat {print $2}' | head -n 1`
[ -n "$GATEWAY" ] || die "Ethernet interface ${IFACE} has no Gateway"
echo "${GATEWAY}"
