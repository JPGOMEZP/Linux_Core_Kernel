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
#     - Took 'run_test()', 'die()', and 'do_cmd()' functions from LTP-DDT
#       project.
#     - Added 'test_environment()' function.
#     - Aligned it to the LCK project standard.
# Apr, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Updated script in order to get more accurate Platform and
#       Kernel version.
# May, 2016.
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Added logic to removes all newlines, leading spaces, tabs and '#'
# Aug, 2016
#   Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Added 'skip_tests()' function in order to skip such functions that
#       are not executed on a platform, and its call from 'run_test()'.
#     - Added 'get_platform()' and 'get_kernel_in_use()' functions to get
#       platform under use and Kernel type in use respectively.
#     - Updated 'test_environment()' function, reusing code from
#	'get_platform()' and 'get_kernel_in_use()' functions.

############################ DESCRIPTION ######################################

# This script contains four main functions:
#
#   - test_environment(): gets the test environment like OS,
#     Kernel, BIOS, Platform, FW and print out them.
#
#   - run_test(): reads the scenario tests and eexecute them.
#
#   - die(): kill the current process if there is a test error.
#
#   - do_cmd(): executes commands

############################# FUNCTIONS #######################################

source "st_log.sh"

KB=1024
MB=1048576
GB=$((1024*1024*1024))
BUILTIN_DIR="/lib/modules/$(uname -r)/modules.builtin"
WDT_LOG_DIR="~/work/LCK-Test/logs/watchdog"

export thispath=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

get_platform()
{
  PRODUCT_NAME=$(dmidecode -t 1 | grep "Product Name" | cut -d":" -f2 | cut -d' ' -f2)
  if [ $PRODUCT_NAME == "Skylake" ]; then
    PLATFORM="skl"
  elif [ $PRODUCT_NAME == "Broxton" ]; then
    PLATFORM="bxt"
  elif [ $PRODUCT_NAME == "Kabylake" ]; then
    PLATFORM="kbl"
  elif [ $PRODUCT_NAME == "Geminilake" ]; then
    PLATFORM="glk"
  fi

  echo ${PLATFORM}
}

get_kernel_in_use()
{
  KERNEL_NAME=$(uname -r)
  if [ `echo $KERNEL_NAME | grep ""` ]; then
    KERNEL="module"
  elif [ `echo $KERNEL_NAME | grep "usb"` ]; then
    KERNEL="module"
  elif [ `echo $KERNEL_NAME | grep "builtin"` ]; then
    KERNEL="builtin"
  fi

  echo ${KERNEL}
}

# GET SYSTEM ENVIRONMENT
test_environment()
{
  OS_VERSION=$(uname -o)
  UBUNTU_VERSION=$(lsb_release -d | cut -d':' -f2 | tr -d '\t')
  BIOS_VERSION=$(dmidecode -t 0 | grep "BIOS Revision" | cut -d":" -f2 | cut -d' ' -f2)
  FIRMWARE_VERSION=$(dmidecode -t 0 | grep "Firmware Revision" | cut -d":" -f2 | cut -d' ' -f2)
  KERNEL_VERSION=$(uname -r | cut -d'-' --fields=1,2)

  echo -e "\n====================== ENVIRONMENT TEST ======================\n"

  test_print_trc "OS_VERSION: $OS_VERSION"
  test_print_trc "UBUNTU_VERSION: $UBUNTU_VERSION"
  test_print_trc "KERNEL_VERSION: $KERNEL_VERSION"
  test_print_trc "BIOS_VERSION: $BIOS_VERSION"
  test_print_trc "PLATFORM: $DUT"
  test_print_trc "FIRMWARE_VERSION: $FIRMWARE_VERSION"
  test_print_trc "TEST TYPE: $TEST_TYPE"
  test_print_trc "KERNEL TYPE: $KERNEL_TYPE"

  echo -e "\n========================== RUN TESTS =========================\n"

}

# EXECUTE TESTS
run_test()
{
   SUITE=$1
   if [ -a "$RUNTEST/$SUITE" ]; then
     sed -e '/^$/ d' -e 's/^[ ,\t]*//' -e '/^#/ d' < ${RUNTEST}/${SUITE} > ${RUNTEST}/${SUITE}.tmp
     skip_tests "${RUNTEST}/${SUITE}.tmp"
     while read line
     do
       regx='^#'
       if ! [[ $line =~ $regx ]]; then
         TAG=`echo $line | awk '{print $1}'`
         CMD=`echo $line | sed 's/^[A-Z0-9_]\+\s//'`

         echo -e "\n"
         if [ -n "$TAG" ] && [ -n "$CMD" ]; then
           test_print_start "RUNING TEST: $TAG"
           eval $CMD
           if [ $? -eq 0 ]; then
             test_print_end "=== TEST $TAG PASS ==="
           else
             test_print_err "=== TEST $TAG FAIL ==="
           fi
         fi
       fi
     done < ${RUNTEST}/${SUITE}.tmp
   else
     test_print_err "Could not find $RUNTEST/$SUITE"
   fi

   rm ${RUNTEST}/${SUITE}.tmp
}

skip_tests()
{
  dut=$(get_platform)

  TS=$1
  while read test
  do
    NAME=`echo $test | awk '{print $1}'`
    if [ `grep ${NAME} ${HOME}/otc_lck_gdc_mx_test_suite-lck_suite/skips/${dut}` ]; then
      sed -i '/'${NAME}'/d' ${TS}
    fi
  done < $TS
}

# KILL PROCESSES
die() {
  test_print_err $0 $LINENO "FATAL: $*"
  exit 1
}

inverted_return="false"

# EXECUTE TESTS/COMMANDS
do_cmd() {
  CMD=$*
  test_print_trc "Inside do_cmd:CMD=$CMD"
  eval $CMD
  RESULT=$?
    if [ "$inverted_return" == "false" ]
    then
      if [ $RESULT -ne 0 ]
      then
        test_print_err "$CMD failed. Return code is $RESULT"
        exit $RESULT
      fi
    else
        if [ $RESULT -eq 0 ]
        then
        test_print_err "$CMD passed. It should fail."
        exit 1
        fi
    fi
}

check_koption()
{
        local koption="$1"
        local value=""
        if [ -r "/boot/config-$(uname -r)" ];then
                value=`cat "/boot/config-$(uname -r)" | grep -E "^$koption=" | cut -d'=' -f2`
        elif [ -r "/proc/config.gz" ];then
                value=`zcat "/proc/config.gz" | grep -E "^$koption=" | cut -d'=' -f2`
        else
                #If /boot/config-`uname -r` and /proc/config.gz all don't exist.
                #Exit, output error message
                die "No config file readable on this system"
        fi
        if [ "x$value" == "x" ];then
                #value equal neither m nor y, output error message
                die "The kernel config option $koption is not set"
        fi
        #The value either equal m or y.
        echo $value
}

check_kernel_errors()
{
  local type=$1
  shift
  local opts=$1
  case $type in
    kmemleak)
      check_config_options "y" DEBUG_KMEMLEAK
      kmemleaks="/sys/kernel/debug/kmemleak"
      if [ ! -e ${kmemleaks} ]; then
        die "kmemleak sys entry doesn't exist; perhaps need to increase CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE"
      fi

      if [ "$opts" = "clear" ]; then
        # clear the list of all current possible memory leaks before scan
        do_cmd "echo clear > ${kmemleaks}"
        return
      fi

      # trigger memory scan
      do_cmd "echo scan > ${kmemleaks}"
      # give kernel some time to scan
      do_cmd sleep 30
      kmemleak_detail=`cat ${kmemleaks}`
      if [ -n "${kmemleak_detail}" ]; then
        die "There are memory leaks being detected. The details are displayed as below: ${kmemleak_detail}"
      else
        test_print_trc "No memory leaks being detected."
      fi

    ;;
    spinlock)
      check_config_options "y" DEBUG_SPINLOCK

      if [ "$opts" = "clear" ]; then
        dmesg -c
        return
      fi

      # Check dmesg to catch the error
      spinlock_errors="BUG: spinlock"
      dmesg |grep -i "${spinlock_errors}" && die "There is spinlock errors showing in dmesg" || test_print_trc "No spinlock related error found in dmesg"
    ;;
    *)
	 die "check_kernel_errors: No logic for type $type yet."
    ;;
  esac
}


# $1: check type, either 'y', 'm', 'ym' or 'n'
# $2: Options to check. Uses same syntax returned by get_modular_config.names.sh
#     which is CONFIG1^CONFIG2:module1 CONFIG3:module2
# It is also possible to use OR like CONFIG1|CONFIG2
function check_config_options()
{
    local koption_values="$1"
    local koption_names=""
    local OPTIONS_LIST=""
    code=0
    local exit_code=1

    # Set kernel option value to check
    case $koption_values in
        y) check='=y';;
        m) check='=m';;
        ym) check='(=y|=m)';;
        n) check=' is not set';;
        *) die "$koption_values is not a valid check_config_options() option"
    esac

    shift

    # Backup current IFS separator and set a new one
    OIFS=$IFS

    # Retrieve kernel options to parse
    koption_names=$*
    IFS='|'

    # For each expression between '|' separators
    for rule in $koption_names
    do
        # Skip empty values
        if [ -z "$rule" ]; then continue; fi

        # Strip ':module' from options
        IFS=' '
        for option in $rule
        do
            options_name=`echo $option | cut -d ':' -f 1`
            # Retrieve kernel options betwwen '^' separators
            IFS='^'
            for option_name in $options_name
            do
                OPTIONS_LIST="$OPTIONS_LIST $option_name"
            done
            IFS=' '
        done

        code=0
        if [ -r "/proc/config.gz" ]
        then
            for option in $OPTIONS_LIST
            do
                if [ -z "$option" ]; then continue; fi
                zcat "/proc/config.gz" | egrep "$option$check" || (IFS=$OIFS; \
                if is_opt_config "$option"; then skip_test "optional $option not enabled"; else die "$option is not $check"; fi)
                if [ $? -eq 1 ]; then code=1; break; fi
            done
        elif [ -r "/boot/config-$(uname -r)" ]
        then
            for option in $OPTIONS_LIST
            do
                if [ -z "$option" ]; then continue; fi
                cat "/boot/config-$(uname -r)" | egrep "$option$check" || (IFS=$OIFS; \
                if is_opt_config "$option"; then skip_test "optional $option not enabled"; else die "$option is not $check"; fi)
                if [ $? -eq 1 ]; then code=1; break; fi
            done
        else
            IFS=$OIFS
            die "No config file readable on this system"
        fi

        if [ $code == 0 ]
        then
            exit_code=0
            break
	fi

     done

        IFS=$OIFS
	if [ $exit_code == 1 ]; then exit 1; fi
}
