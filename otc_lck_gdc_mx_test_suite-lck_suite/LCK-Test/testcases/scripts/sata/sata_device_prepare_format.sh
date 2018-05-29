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
# Jan, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Initial draft.
#     - Merged 'blk_device_erase_format_part.sh', 'blk_device_prepare_format.sh',
#       'blk_device_umount.sh' and 'blk_device_do_mount.sh' from LTP-DDT
#       into this script.
#     - Modified script to align to LCK standard.

############################# DESCRIPTION #####################################

# This script mount, unmount and formt Device Node in different FS.

############################# FUNCTIONS #######################################

usage()
{
cat <<-EOF >&2
        usage: ./${0##*/} [-n DEV_NODE] [-d DEVICE_TYPE] [-f FS_TYPE] [-m MNT_POINT] [-o MNT_MODE]
	-n DEV_NODE	optional param; device node like /dev/mtdblock2; /dev/sda1
        -f FS_TYPE      filesystem type like vfat, ext2, etc
        -m MNT_POINT	  mount point
        -o MNT_MODE     mount mode: 'async' or 'sync'. default is 'async'
        -d DEVICE_TYPE  device type like 'mmc', 'emmc'
        -h Help         print this usage
EOF
exit 0
}

############################ DO THE WORK ######################################

source "common.sh"

while getopts  :d:f:m:n:o:ush arg
do case $arg in
        d)  DEVICE_TYPE="$OPTARG";;
        n)  DEV_NODE="$OPTARG";;
        f)  FS_TYPE="$OPTARG";;
        m)  MNT_POINT="$OPTARG";;
        o)  MNT_MODE="$OPTARG";;
        u)  UMOUNT=1;;
        s)  SKIP=1;;
        h)  usage;;
        :)  test_print_trc "$0: Must supply an argument to -$OPTARG." >&2
            exit 1
            ;;
        \?) test_print_trc "Invalid Option -$OPTARG ignored." >&2
            usage
            exit 1
            ;;
esac
done

: ${MNT_MODE:='async'}
: ${UMOUNT:='0'}
: ${SKIP:='0'}

if [ $UMOUNT -eq 0 ]; then
  if [ $SKIP -eq 0 ]; then
    # SET FS TO FORMAT DEVICE NODE
    test_print_trc "FORMAT $DEV_NODE"
    if [ "$FS_TYPE" = "vfat" ]; then
      MKFS="mkfs.${FS_TYPE} -F 32"
    elif [ -n "$FS_TYPE" ]; then
      MKFS="mkfs.${FS_TYPE}"
    else
      die "FS_TYPE can not be empty !"
    fi

    [ -z "$DEV_NODE" ] && die "Arguments missing !"

    # UMOUNT DEVICE NODE IF IT IS MOUNTED
    test_print_trc "UMOUNT $DEV_NODE IF IT IS MOUNTED"
    do_cmd "mount" | grep "$DEV_NODE" && \
    CUR_MNT_POINT=`mount | grep $DEV_NODE | cut -d' ' -f3` && \
    do_cmd "umount $CUR_MNT_POINT"
    sleep 2

    # FORMAT THE DEVICE NODE
    do_cmd "${MKFS} $DEV_NODE"

    # UMOUNT MOUNT POINT IF PREVIOUSLY MOUNTED WITH OTHER DEVICE NODE
    test_print_trc "UMOUNT MOUNT POINT IF IT IS MOUNTED"
    do_cmd mount | grep $MNT_POINT && do_cmd umount "$MNT_POINT"
    sleep 2
  fi

  # MOUNT PARTITION
  test_print_trc "MOUNT THE PARTITION"
  mount -t "$FS_TYPE" -o "$MNT_MODE" "$DEV_NODE" "$MNT_POINT"
  mount | grep "$MNT_POINT"
else
  do_cmd umount "$MNT_POINT"
fi
