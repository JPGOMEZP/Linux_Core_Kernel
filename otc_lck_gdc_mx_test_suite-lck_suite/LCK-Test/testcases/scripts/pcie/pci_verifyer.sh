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
###############################################################################

############################ CONTRIBUTORS #####################################

# Author: Juan Carlos Alonso (juan.carlos.alonso@intel.com)
#
# Jan, 2016. Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#   - Create script to run PCIe BATs tests.

############################ DESCRIPTION ######################################

# This script does:
#   - Verify PCIe port Kernel Driver is loaded.
#   - Verify PCIe root port class code.
#   - Verify GBE Intel Card enumeration on PCIe root port.
#   - List PCIe modules loaded.
#   - Verify number of PCIe roots ports.
#   - Verify PCI root port vendor ID

############################ FUNCTIONS ########################################

############################ DO THE WORK ######################################

source "common.sh"

while getopts :kcemnih arg
do case $arg in
  k)  PORT_DRIVER=1;;
  c)  PORT_CLASS=1;;
  e)  ENUM_DEVICE=1;;
  m)  LIST=1;;
  n)  PORT_NUMBER=1;;
  i)  PORT_ID=1;;
  h)  usage;;
  \?) test_print_trc "Invalid Option -$OPTARG ignored." >&2
      usage
      exit 1 ;;
  esac
done

# DEFAULT VALUES IF NOT SET IN 'getopts'
: ${PORT_DRIVER:='0'}
: ${PORT_CLASS:='0'}
: ${ENUM_DEVICE:='0'}
: ${LIST:='0'}
: ${PORT_NUMBER:='0'}
: ${PORT_ID:='0'}

PCI_ID=`lspci -D | grep PCI | cut -d' ' -f1 | head -1`

# LOOK FOR PCI PORT KERNEL DRIVER
if [ $PORT_DRIVER -eq 1 ]; then
  PORT_KD=`lspci -D | grep $PCI_ID`
  ls -l $PCI_DIR/$PCI_ID > /dev/null 2>&1
  if [ $? -eq 0 ]; then
	  test_print_trc "PCIe Port Kernel Driver is loaded: $PORT_KD"
  else
    die "No PCI port was found"
  fi
fi

# LOOK FOR PCI ROOT PORT CLASS
if [ $PORT_CLASS -eq 1 ]; then
  CODE=`cat $PCI_DIR/$PCI_ID/class`
  CODE_NUMBER="0x060400"
  if [ "$CODE" == "$CODE_NUMBER" ]; then
    test_print_trc "PCI Root Port Class Code: $CODE  was verifed "
  else
    die "No PCI root port was found or was not verified"
  fi
fi

if [ $ENUM_DEVICE -eq 1 ]; then
  GBE_CARD=`lspci -vt | grep 1d.0 | cut -d "+" -f2 | sed 's/^ //g'`
  if [ $? -eq 0 ]; then
    test_print_trc "GBE card is properly enumerated: $GBE_CARD "
  else
    die "GBE card was not properly enumerated"
  fi
fi

if [ $LIST -eq 1 ]; then
  PCI_MODULE=`lspci -Dk | grep $PCI_ID`
  if [ $? -eq 0 ]; then
    test_print_trc "PCIe Module is loeaded: $PCI_MODULE"
  else
    die "PCIe Module is not loaded"
  fi
fi

if [ $PORT_NUMBER -eq 1 ]; then
  PCI_ROOT_PORT=`lspci -Dns $PCI_ID | egrep -c "8086"`
  if [ $? -eq 0 ]; then
    test_print_trc "Numbers od PCIe Root Ports are verified: $PCI_ROOT_PORT "
  else
    die "Numbers of PCIe Root Ports are not verified"
  fi
fi

if [ $PORT_ID -eq 1 ]; then
  VID=`cat $PCI_DIR/$PCI_ID/vendor`
  VENDOR_ID=0x8086
  if [ "$VID" = "$VENDOR_ID" ]; then
    test_print_trc "PCI Root Port Vendor ID is verified: $VID "
  else
    die "Vendor ID is not verified"
  fi
fi
