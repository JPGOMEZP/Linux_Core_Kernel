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

############################# CONTRIBUTORS ####################################

# Jan, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Ported from LTP-DDT script.
#     - Modified script to align to LCK standard.

############################# DESCRIPTION #####################################

# This script perform write and read data in different FS (ext2, ext3, ext4,
# and vfat) of different file sizes for an SSD, between two SSDs and HDD for
# different buffer sizes.

############################# FUNCTIONS #######################################

usage()
{
cat <<-EOF >&2
  usage: ./${0##*/} [-f FS_TYPE] [-n DEV_NODE] [-m MOUNT POINT] \
[-B BUFFER SIZES] [-s FILE SIZE] [-d DEVICE TYPE] [-o SYNC or ASYNC] [-t TIME_OUT]
  -f FS_TYPE	filesystem type like jffs2, ext2, etc
  -n DEV_NODE	optional param, block device node like /dev/mtdblock4, /dev/sda1
  -m MNT_POINT	optional param, mount point like /mnt/mmc
  -B BUFFER_SIZES	optional param, buffer sizes for perf test like '102400 262144 524288 1048576 5242880'
  -s FILE SIZE 	optional param, file size in MB for perf test
  -c SRCFILE SIZE 	optional param, srcfile size in MB for writing to device
  -d DEVICE_TYPE	device type like 'nand', 'mmc', 'usb' etc
  -o MNT_MODE     mount mode: sync or async. default is async
  -t TIME_OUT  time out duratiopn for copying
  -S SKIP_FORMAT      skip erase/format part and just do r/w
  -h Help 	print this usage
EOF
exit 0
}

############################ DO THE WORK ######################################

source "common.sh"

if [ $# == 0 ]; then
	echo "Please provide options; see usage"
	usage
	exit 1
fi

while getopts  :n:f:b:s:d:Sh arg
do case $arg in
  n)  DEV_NODE_1="$OPTARG";;
  f)  FS_TYPE="$OPTARG";;
  b)  BUFFER_SIZES="$OPTARG";;
  s)  FILE_SIZE="$OPTARG";;
  d)  DEVICE_TYPE="$OPTARG";;
  S)  SKIP_FORMAT=1;;
  h)  usage;;
  :)  test_print_trc "$0: Must supply an argument to -$OPTARG." >&2
      exit 1
      ;;
  \?)   test_print_trc "Invalid Option -$OPTARG ignored." >&2
        usage
        exit 1
        ;;
  esac
done

# DEFAULT VALUES IF NOT SET IN 'getopts'
: ${BUFFER_SIZES:='102400 262144 524288'}
: ${FILE_SIZE:='100'}
: ${SRCFILE_SIZE:='10'}
: ${MNT_MODE:='async'}
: ${TIME_OUT:='30'}
: ${SKIP_FORMAT:='0'}

#SET MOUNT POINT FOR DEV_NODE_1
MNT_POINT_1="$TEST_MNT_DIR_1/${DEVICE_TYPE}_$$"

# CREATE MOUNT POINTS FOR DEV_NODE
[ -d "$TEST_TMP_DIR" ] || do_cmd mkdir -p "$TEST_TMP_DIR" > /dev/null
[ -d "$MNT_POINT_1" ] || do_cmd mkdir -p "$MNT_POINT_1" > /dev/null

# GET DEVICE NODE
if [ -z $DEV_NODE_1 ]; then
  DEV_NODE_1=`sata_get_device_node.sh "$DEVICE_TYPE" "ssd1"` || \
  die "error getting device node for $DEVICE_TYPE"
fi

# PRINT TEST INFO
test_print_trc "DEVICE_TYPE:${DEVICE_TYPE}"
test_print_trc "FS_TYPE:${FS_TYPE}"
test_print_trc "DEV_NODE_1:${DEV_NODE_1}"
test_print_trc "MOUNT POINT_1:${MNT_POINT_1}"
test_print_trc "BUFFER SIZES:${BUFFER_SIZES}"
test_print_trc "FILE SIZE:${FILE_SIZE}MB"
test_print_trc "SRCFILE SIZE:${SRCFILE_SIZE}MB"

# RUN FILESYSTEM PERFORMANCE TEST
test_print_trc "STARTING FILE SYSTEM PERFORMANCE TEST FOR $DEVICE_TYPE"
for BUFFER_SIZE in $BUFFER_SIZES; do
	test_print_trc "BUFFER SIZE = $BUFFER_SIZE"
	test_print_trc "CHECKING IF BUFFER SIZE IS VALID"
	[ $BUFFER_SIZE -gt $(( $FILE_SIZE * $MB )) ] && die "Buffer size provided:$BUFFER_SIZE is not less than or equal to File size $FILE_SIZE MB"

  # MOUNT DEVICE NODE
  sata_device_prepare_format.sh -d "$DEVICE_TYPE" -n "$DEV_NODE_1" -f "$FS_TYPE" -m "$MNT_POINT_1"

  # CREATE SOURCE FILE
	test_print_trc "CREATE SOURCE FILE"
  SRC_FILE="$TEST_TMP_DIR/src_file_${BUFFER_SIZE}"
	do_cmd "dd if=/dev/urandom of=$SRC_FILE bs=1M count=$SRCFILE_SIZE"
  do_cmd ls -lh $SRC_FILE
  if [ $? -eq 0 ]; then
    test_print_trc "SOURCE FILE CREATED SUCCESSFULLY"
  else
   die "CANNOT CREATE SOURCE FILE"
  fi

  TEST_FILE_1="${MNT_POINT_1}/test_file_${BUFFER_SIZE}"

  # FILESYSTEM WRITE TEST.
  do_cmd "filesystem_tests -write -src_file $SRC_FILE -srcfile_size $SRCFILE_SIZE -file ${TEST_FILE_1} -buffer_size $BUFFER_SIZE -file_size $FILE_SIZE -performance"
	do_cmd "rm -f $SRC_FILE"
	do_cmd "sync"

  # SHOULD DO UMOUNT AND MOUNT BEFORE READ
  do_cmd sata_device_prepare_format.sh -u -m "$MNT_POINT_1"
  do_cmd "echo 3 > /proc/sys/vm/drop_caches"
  do_cmd sata_device_prepare_format.sh -d "$DEVICE_TYPE" -n "$DEV_NODE_1" -f "$FS_TYPE" -m "$MNT_POINT_1" -s
	do_cmd "filesystem_tests -read -file ${TEST_FILE_1} -buffer_size $BUFFER_SIZE -file_size $FILE_SIZE -performance"
  do_cmd "sync"
	do_cmd "echo 3 > /proc/sys/vm/drop_caches"

  # FOR COPY TEST, ONLY DO HALF OF FILE SIZE TO AVOID OUT OF SPARE PROBLEM
  test_print_trc "CREATING FILE WICH IS HALF SIZE OF $FILE_SIZE TO MAKE COPY FILE"
  HALF_FILE_SIZE=$(awk "BEGIN {print $FILE_SIZE/2}")
  TEST_FILE="$TEST_TMP_DIR/test_file_${BUFFER_SIZE}"
  DST_TEST_FILE="$MNT_POINT_1/dst_test_file_${BUFFER_SIZE}"
  do_cmd "dd if=/dev/urandom of=${TEST_FILE} bs=524288 count=$FILE_SIZE"
  do_cmd filesystem_tests -copy -src_file ${TEST_FILE} -dst_file ${DST_TEST_FILE} -duration ${TIME_OUT} -buffer_size $BUFFER_SIZE -file_size $HALF_FILE_SIZE -performance

  # UNMOUNT DEVICE BEFORE NEXT BUFFER SIZE
  test_print_trc "UMOUNT THE DEVICE"
  do_cmd sata_device_prepare_format.sh -u -m "$MNT_POINT_1"
done

# DELETE TEMP, MOUNT AND TEST DIRECTORIES
test_print_trc "REMOVING TEST DIRECTORY"
do_cmd rm -rf $TEST_DIR
