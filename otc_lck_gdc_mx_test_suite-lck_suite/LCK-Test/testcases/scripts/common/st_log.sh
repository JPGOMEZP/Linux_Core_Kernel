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
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Aligned it to the LCK project standard.

############################ DESCRIPTION ######################################

# This script contains routines for printing the logs, prints the trace log.
#
#   - test_print_trc(): prints trace log.
#
#   - test_print_start(): prints test start.
#
#   - test_print_end(): prints test end.
#
#   - test_print_result(): print test result.
#
#   - test_print_wrg(): print test warning.
#
#   - test_print_err(): print test error.

############################# FUNCTIONS #######################################

# PRINT TEST INFORMATION
test_print_trc()
{
	log_info=$1

	echo "|TRACE LOG|$log_info|"
}

# PRINT TEST START
test_print_start()
{
	id=$1

	# WAIT UNTIL ALL THE KERNEL LOGS FUSHES OUT
	sleep 1

	echo "|TEST START|$id|"
}

# PRINT TEST END
test_print_end()
{
	id=$1				# testcase id

	# WAIT UNTIL ALL THE KERNEL LOGS FUSHES OUT
	sleep 1

	echo "|TEST END|$id|"
}

# PRINT TEST RESULT
test_print_result()
{
	result=$1
	id=$2

	# WAIT UNTIL ALL THE KERNEL LOGS FUSHES OUT
	sleep 1

	echo "|TEST RESULT|$result|$id|"
}

# PRINT TEST WARNING
test_print_wrg()
{
	file_name=$1
	line=$2
	warning=$3

	echo "|WARNING|Line:$line File:$file_name - $warning|"
}

# PRINT TEST ERROR
test_print_err()
{
	file_name=$1
	line=$2
	error=$3

	echo "|ERROR|Line:$line File:$file_name - $error|"
}
