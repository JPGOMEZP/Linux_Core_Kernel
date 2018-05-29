#!/bin/bash

###############################################################################
#
# Copyright (C) 2015 Intel - http://www.intel.com
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

############################ CONTRIBUTORS ######################################

# @Author   Zelin Deng (zelinx.deng@intel.com)

############################# DESCRIPTION #####################################

# @desc     check dmesg of xhci module init
# @returns  0 if the execution was finished successfully, else 1
# @history  2015-12-22: First Version (Zelin Deng)

############################# FUNCTIONS #######################################

############################ DO THE WORK ######################################

source "common.sh"

[ $# -ne 1 ] && die "You must appoint which case to be executed: initcall or dmesg. ${0##*/} <CASE_ID>"

CASE_ID="$1"
echo $CASE_ID | grep -E "^initcall$|^dmesg$"
if [ $? -ne 0 ];then
	die "CASE_ID must be initcall or dmesg"
fi

# CHECK PRECONDITION. 'xhci' MUST BE CONFIGURED AS MODULE OR BUILTIN
kconfig=`check_koption "CONFIG_USB_XHCI_PCI"`
if [ "$kconfig" != 'm' ];then
	test_print_trc "Kernel config CONFIG_USB_XHCI_PCI must be configured as module"
	exit 2
fi

xhciMod=$(lsmod | grep -i 'xhci_pci' | awk '{print $1}' | grep -i 'xhci_pci')

if [ "x$xhciMod" != "xxhci_pci" ];then
	die "module xhci_pci is not load"
else
	case $CASE_ID in
		initcall)
			#Check if initcall_debug has been enabled in cmdline
			cat /proc/cmdline | grep -ow initcall_debug
			if [ $? -ne 0 ];then
				test_print_trc "initcall_debug option must be enabled in cmdline"
				exit 2
			fi
			respReq=50000
			xhciInit=$(modprobe -rf xhci_pci; sleep 10; modprobe xhci_pci; dmesg | grep -i initcall | grep -i xhci_pci | tail -n 1 | grep -Po "(?<=after )[[:digit:]]*")
			if [ $xhciInit -lt $respReq ]; then
				test_print_trc "Successfully, time to initiate xhci_pci module is $xhciInit less than $respReq"
				exit 0
			else
				die "Failed, time to initiate xhci_pci module is $xhciInit larger than $respReq"
			fi
		;;
		dmesg)
			#check dmesg to check if there's any issue
			dmesg | grep -iE "00:14|xhci_pci" | grep -iE "error|fatal|unable|fail"
			if [ $? -eq 0 ];then
				die "Failed, XHCI errors in dmesg detected"
			fi
			test_print_trc "Successfully, no XHCI errors in dmesg detected"
			exit 0
		;;
	esac
fi
