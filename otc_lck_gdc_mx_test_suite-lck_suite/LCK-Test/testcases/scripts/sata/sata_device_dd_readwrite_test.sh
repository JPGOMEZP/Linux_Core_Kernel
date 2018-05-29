#!/bin/bash

################################################################################
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
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Ported from LTP-DDT project.
#     - Modified script to align to LCK standard.
#     - Added logic to support data transfer between 2 SSDs

############################# DESCRIPTION #####################################

# This script perform write and read data in different FS (ext2, ext3, ext4,
# and vfat) of different file sizes for an SSD, between two SSDs and HDD.

############################# FUNCTIONS #######################################

usage()
{
cat <<-EOF >&2
  usage: ./${0##*/} [-n DEV_NODE] [-d DEVICE_TYPE] [-f FS_TYPE] [-m MNT_POINT]\
[-b DD_BUFSIZE] [-c DD_CNT] [-i IO_OPERATION] [-l TEST_LOOP] [-s SKIP_FORMAT] \
[-w WRITE_TO_FILLUP]
  -n DEV_NODE         optional param; device node like /dev/mtdblock2; /dev/sda1
  -f FS_TYPE          filesystem type like jffs2, ext2, etc
  -m MNT_POINT        mount point
  -b DD_BUFSIZE       dd buffer size for 'bs'
  -c DD_CNT           dd count for 'count'
  -i IO_OPERATION     IO operation like 'wr', 'cp', default is 'wr'. \
'oversize_write' is to test if driver throw error when the size > partition size
  -d DEVICE_TYPE      device type like 'nand', 'mmc', 'usb' etc
  -l TEST_LOOP        test loop for r/w. default is 1.
  -w WRITE_TO_FILLUP  keep writing different files TEST_LOOP times to device
  -h Help             print this usage
EOF
exit 0
}

# md5sum
compare_md5sum()
{
  FILE1=$1
  FILE2=$2
  a=$(md5sum "$FILE1"|cut -d' ' -f1)
  echo "$1: $a"
  b=$(md5sum "$FILE2"|cut -d' ' -f1)
  echo "$2: $b"
  [ "$a" = "$b" ]
}

############################ DO THE WORK ######################################

source "common.sh"

while getopts :n:a:d:f:n:b:c:i:l:th arg
do case $arg in
        n)  DEV_NODE_1="$OPTARG";;
        a)  DEV_NODE_2="$OPTARG";;
        d)  DEVICE_TYPE="$OPTARG";;
        f)  FS_TYPE="$OPTARG";;
        b)  DD_BUFSIZE="$OPTARG";;
        c)  DD_CNT="$OPTARG";;
        i)  IO_OPERATION="$OPTARG";;
        l)  TEST_LOOP="$OPTARG";;
        t)  SSD_TO_SSD=1;;
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

# DEFAULT VALUES IF NOT SET IN 'getopts'
: ${IO_OPERATION:='wr'}
: ${TEST_LOOP:='1'}
: ${SKIP_FORMAT:='0'}
: ${WRITE_TO_FILL:='0'}
: ${SSD_TO_SSD:='0'}

#SET MOUNT POINT FOR DEV_NODE_1 AND DEV_NODE_2
MNT_POINT_1="$TEST_MNT_DIR_1/${DEVICE_TYPE}_$$"
MNT_POINT_2="$TEST_MNT_DIR_2/${DEVICE_TYPE}_$$"
x=0

# CREATE MOUNT POINTS FOR DEV_NODE_1, AND DEV_NODE_2 IF NEEDED
[ -d "$TEST_TMP_DIR" ] || do_cmd mkdir -p "$TEST_TMP_DIR" > /dev/null
[ -d "$MNT_POINT_1" ] || do_cmd mkdir -p "$MNT_POINT_1" > /dev/null

if [ $SSD_TO_SSD -eq 1 ]; then
  [ -d "$MNT_POINT_2" ] || do_cmd mkdir -p "$MNT_POINT_2" > /dev/null
fi

# FIND DEVICE NODE FOR DEV_NODE_1, AND DEV_NODE_2 IF NEEDED
if [ -z $DEV_NODE_1 ]; then
  DEV_NODE_1=`sata_get_device_node.sh "$DEVICE_TYPE" "ssd1"` || \
  die "error getting device node for $DEVICE_TYPE: $DEV_NODE_1"
fi

if [ $SSD_TO_SSD -eq 1 ] && [ -z $DEV_NODE_2 ]; then
  DEV_NODE_2=`sata_get_device_node.sh "$DEVICE_TYPE" "ssd2"` || \
  die "error getting device node for $DEVICE_TYPE: $DEV_NODE_2"
fi

# PRINT TEST INFO
test_print_trc "DEVICE TYPE: $DEVICE_TYPE"
test_print_trc "FS_TYPE: $FS_TYPE"
test_print_trc "DEV_NODE_1: $DEV_NODE_1"
test_print_trc "MNT_POINT_1: $MNT_POINT_1"
if [ $SSD_TO_SSD -eq 1 ]; then
  test_print_trc "DEV_NODE_2: $DEV_NODE_2"
  test_print_trc "MNT_POINT_2: $MNT_POINT_2"
fi

# MOUNT DEVICE NODE OF DEV_NODE_1, AND DEV_NODE_2 IF NEEDED
do_cmd sata_device_prepare_format.sh -d "$DEVICE_TYPE" -n "$DEV_NODE_1" -f "$FS_TYPE" -m "$MNT_POINT_1"
if [ $SSD_TO_SSD -eq 1 ]; then
  do_cmd sata_device_prepare_format.sh -d "$DEVICE_TYPE" -n "$DEV_NODE_2" -f "$FS_TYPE" -m "$MNT_POINT_2"
fi

# TEST IS ABOUT TO START
if [ $SSD_TO_SSD -eq 1 ]; then
  test_print_trc "DOING READ/WRITE TEST BETWEEN SSD1 AND SSD2 $TEST_LOOP TIMES"
else
  test_print_trc "DOING READ/WRITE TEST FOR $TEST_LOOP TIMES"
fi

# CREATE SOURCE FILE
test_print_trc "CREATE SOURCE FILE"
SRC_FILE="$TEST_TMP_DIR/src_file_$$"
do_cmd "dd if=/dev/urandom of=$SRC_FILE bs=$DD_BUFSIZE count=$DD_CNT"
do_cmd ls -lh $SRC_FILE
if [ $? -eq 0 ]; then
  test_print_trc "SOURCE FILE CREATED SUCCESSFULLY"
else
  die "CANNOT CREATE SOURCE FILE"
fi

# START TEST WRITE, READ
while [ $x -lt $TEST_LOOP ]
do
  echo "============R/W LOOP: $x============"

  case $IO_OPERATION in
    wr) TEST_FILE_1="${MNT_POINT_1}/test_file_$$_${x}"

        # WRITE TO DEVICE NODE 1
        test_print_trc "WRITE IN DEVICE NODE 1"
        do_cmd dd if="$SRC_FILE" of="$TEST_FILE_1" bs=$DD_BUFSIZE count=$DD_CNT
        do_cmd ls -lh $TEST_FILE_1

        # READ DEVICE NODE 1
        test_print_trc "DOING READ OF DEVICE NODE 1"
        do_cmd diff "$SRC_FILE" "$TEST_FILE_1"
        if [ $? -ne 0 ]; then
          do_cmd cmp -l "$SRC_FILE" "$TEST_FILE_1"
        fi

        # DELETE TEST FILE 1
        test_print_trc "DELETE TEST FILE 1"
        do_cmd dd if=$TEST_FILE_1 of=/dev/null bs=$DD_BUFSIZE count=$DD_CNT
        do_cmd "sync"
        do_cmd "echo 3 > /proc/sys/vm/drop_caches"
        ;;

  sts)  TEST_FILE_1_1="${MNT_POINT_1}/test_file_1_$$_${x}"
        TEST_FILE_1_2="${MNT_POINT_2}/test_file_1_$$_${x}"
        TEST_FILE_2_1="${MNT_POINT_1}/test_file_2_$$_${x}"
        TEST_FILE_2_2="${MNT_POINT_2}/test_file_2_$$_${x}"

        # WRITE TO DEVICE NODE 1
        test_print_trc "WRITE IN DEVICE NODE 1"
        do_cmd dd if="$SRC_FILE" of="$TEST_FILE_1_1" bs=$DD_BUFSIZE count=$DD_CNT
        do_cmd ls -lh $TEST_FILE_1_1

        # WRITE FROM DEVICE NODE 1 TO DEVICE NODE 2
        test_print_trc "DOING WRITE FROM DEVICE NODE 1 TO DEVICE NODE 2"
        do_cmd dd if="$TEST_FILE_1_1" of="$TEST_FILE_1_2" bs=$DD_BUFSIZE count=$DD_CNT
        do_cmd ls -lh $TEST_FILE_1_2

        # READ DEVICE NODE 2
        test_print_trc "DOING READ OF DEVICE NODE 2"
        do_cmd diff "$TEST_FILE_1_1" "$TEST_FILE_1_2"
        if [ $? -ne 0 ]; then
          do_cmd cmp -l "$TEST_FILE_1_1" "$TEST_FILE_1_2"
        fi

        # WRITE TO DEVICE NODE 2
        test_print_trc "WRITE IN DEVICE NODE 2"
        do_cmd dd if=/dev/urandom of=$TEST_FILE_2_2 bs=$DD_BUFSIZE count=$DD_CNT
        do_cmd ls -lh $TEST_FILE_2_2

        # WRITE FROM DEVICE NODE 2 TO DEVICE NODE 1
        test_print_trc "DOING WRITE FROM DEVICE NODE 2 TO DEVICE NODE 1"
        do_cmd dd if=$TEST_FILE_2_2 of=$TEST_FILE_2_1 bs=$DD_BUFSIZE count=$DD_CNT
        do_cmd ls -lh $TEST_FILE_2_1

        # READ DEVICE NODE 1
        test_print_trc "DOING READ OF DEVICE NODE 1"
        do_cmd diff "$TEST_FILE_2_2" "$TEST_FILE_2_1"
        if [ $? -ne 0 ]; then
          do_cmd cmp -l "$TEST_FILE_2_2" "$TEST_FILE_2_1"
        fi

        # DELETE TEST FILE IN SSD1 AND SSD2
        test_print_trc "DELETE ALL TEST FILES IN BOTH DEVICE NODES"
        do_cmd dd if=$TEST_FILE_1_1 of=/dev/null bs=$DD_BUFSIZE count=$DD_CNT
        do_cmd dd if=$TEST_FILE_2_1 of=/dev/null bs=$DD_BUFSIZE count=$DD_CNT
        do_cmd dd if=$TEST_FILE_1_2 of=/dev/null bs=$DD_BUFSIZE count=$DD_CNT
        do_cmd dd if=$TEST_FILE_2_2 of=/dev/null bs=$DD_BUFSIZE count=$DD_CNT
        do_cmd "sync"
        do_cmd "echo 3 > /proc/sys/vm/drop_caches"
        ;;

    cp) TEST_FILE_1="${MNT_POINT_1}/test_file_$$_${x}"
	TEST_FILE_2="${MNT_POINT_1}/test_file_2_$$_${x}"

	# COPY SOURCE FILE TO TEST_FILE_1
	test_print_trc "Copy SOURCE_FILE to TEST_FILE_1"
	do_cmd "cp $SRC_FILE $TEST_FILE_1"
        do_cmd sync
        echo 3 > /proc/sys/vm/drop_caches

        do_cmd "ls -lh $SRC_FILE"
        do_cmd "ls -lh $TEST_FILE_1"

        # CHECK 'md5sum' SOURCE FILE AND TEST_FILE_1
	test_print_trc "Compare with md5sum SOURCE_FILE and TEST_FILE_1"
	do_cmd compare_md5sum "$SRC_FILE" "$TEST_FILE_1"
        if [ $? -ne 0 ]; then
          do_cmd "cmp -l $SRC_FILE $TEST_FILE_1"
          die "SOURCE FILE IS NOT EQUAL TO TEST_FILE_1"
	fi
	sleep 1

	# COPY TEST_FILE_1 TO TEST_FILE_2
	test_print_trc "Copy TEST_FILE_1 to TEST_FILE_2"
	do_cmd cp "$TEST_FILE_1" "$TEST_FILE_2"
	do_cmd sync
        echo 3 > /proc/sys/vm/drop_caches

	do_cmd "ls -lh $SRC_FILE"
	do_cmd "ls -lh $TEST_FILE_2"

	# CHECK 'md5sum' SOURCE FILE AND TEST_FILE_2
        test_print_trc "Compare with md5sum SOURCE_FILE and TEST_FILE_2"
        do_cmd compare_md5sum "$SRC_FILE" "$TEST_FILE_2"
	if [ $? -ne 0 ]; then
          do_cmd "cmp -l $SRC_FILE $TEST_FILE_2"
          die "SOURCE FILE IS NOT EQUAL TO TEST_FILE_2"
        fi
        sleep 1

	do_cmd "rm $TEST_FILE_1 $TEST_FILE_2"
	;;
    *)
        test_print_err "Invalid IO operation type in $0 script"
        exit 1;
        ;;
  esac

  x=$((x+1))
done

# DELETE SOURCE FILE
test_print_trc "REMOVE SOURCE FILE"
do_cmd rm -f "$SRC_FILE"

# UMOUNT DEVICE NODES
test_print_trc "UMOUNTING DEVICE NODE 1"
do_cmd sata_device_prepare_format.sh -m "$MNT_POINT_1" -u

if [ $SSD_TO_SSD -eq 1 ]; then
  test_print_trc "UMOUNTING DEVICE NODE 2"
  do_cmd sata_device_prepare_format.sh -m "$MNT_POINT_2" -u
fi

# DELETE TEMP, MOUNT AND TEST DIRECTORIES
test_print_trc "REMOVING TEST DIRECTORY"
do_cmd rm -rf $TEST_DIR
