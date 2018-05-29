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

# Author: sylvainx.heude@intel.com
#
# Jan, 2016. Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#   - Ported from 'otc_kernel_qa-tp_tc_scripts_linux_core_kernel' project to
#     LCK project.
#   - Modified script in order to align it to LCK repository standard.

############################ DESCRIPTION ######################################

# This script looks for EC path

############################ FUNCTIONS ########################################

usage()
{
cat <<-EOF >&2
   usage: ./${0##*/} [-c] [-s] [-b] [-f] [-d] [-i] [-p] [-g] [-m] [-t] [-n] [-h]
     -c  to check STM CORE driver
     -s  to check STM CONSOLE driver
     -b  to check STM HEARTBEAT driver
     -d  to check STM DUMMY driver
     -i  to check ITH driver
     -p  to check ITH PCI driver
     -g  to check ITH GTH driver
     -m  to check ITH MSU driver
     -t  to check ITH STH driver
     -n  to check ITH PTI driver
     -h  print this usage
EOF
exit 0
}


############################ DO THE WORK ######################################

source "common.sh"
source "ith_common.sh"

while getopts :csbfdipgmtnh arg
do case $arg in
	c) DRV="$STM_CORE"
	   DRV_KCONFIG="$STM_CORE_KCONFIG"
	   ;;
	s) DRV="$STM_CONSOLE"
	   DRV_KCONFIG="$STM_CONSOLE_KCONFIG"
	   ;;
	b) DRV="$STM_HEARTBEAT"
	   DRV_KCONFIG="$STM_HEARTBEAT_KCONFIG"
	   ;;
	f) DRV="$STM_FTRACE"
	   DRV_KCONFIG="$STM_FTRACE_KCONFIG"
	   ;;
	d) DRV="$STM_DUMMY"
	   DRV_KCONFIG="$STM_DUMMY_KCONFIG"
	   ;;
	i) DRV="$INTEL_TH"
	   DRV_KCONFIG="$INTEL_TH_KCONFIG"
	   ;;
	p) DRV="$INTEL_TH_PCI"
	   DRV_KCONFIG="$INTEL_TH_PCI_KCONFIG"
	   ;;
	g) DRV="$INTEL_TH_GTH"
  	   DRV_KCONFIG="$INTEL_TH_GTH_KCONFIG"
	   ;;
	m) DRV="$INTEL_TH_MSU"
	   DRV_KCONFIG="$INTEL_TH_MSU_KCONFIG"
 	   ;;
	t) DRV="$INTEL_TH_STH"
	   DRV_KCONFIG="$INTEL_TH_STH_KCONFIG"
	   ;;
	n) DRV="$INTEL_TH_PTI"
	   DRV_KCONFIG="$INTEL_TH_PTI_KCONFIG"
	   ;;
	h) usage ;;
	:) usage
	   ;;
	\?) test_print_trc "Invalid Option -$OPTARG ignored." >&2
	    usage
	    exit 1
	    ;;
  esac
done

test_print_trc "DRV: $DRV"
test_print_trc "DRV_KCONFIG: $DRV_KCONFIG"

kconfig=`check_koption "$DRV_KCONFIG"` || exit 2
test_print_trc "kconfig: $kconfig"

if [ $kconfig = 'm' ];then
	modprobe $DRV
        lsmod | grep $DRV
        if [ $? -ne 0 ];then
                test_print_trc "$DRV module is not loaded"
                exit 2
        fi
fi
