#!/bin/bash

################################################################################
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

# Mar, 2017. Juan Carlos Alonso <juan.carlos.alonso@intel.com>
#     - Initial draft

############################# DESCRIPTION #####################################

# @desc    This script export ITH driver name and sysfs paths.
# @params
# @history 2017-03-13: Initial draft.

############################# FUNCTIONS #######################################

############################ DO THE WORK ######################################

export STM_CORE="stm_core"
export STM_CONSOLE="stm_console"
export STM_HEARTBEAT="stm_heartbeat"
export STM_FTRACE="stm_ftrace"
export STM_DUMMY="dummy_stm"

export STM_CORE_KCONFIG="CONFIG_STM"
export STM_CONSOLE_KCONFIG="CONFIG_STM_SOURCE_CONSOLE"
export STM_HEARTBEAT_KCONFIG="CONFIG_STM_SOURCE_HEARTBEAT"
export STM_FTRACE_KCONFIG="CONFIG_STM_SOURCE_FTRACE"
export STM_DUMMY_KCONFIG="CONFIG_STM_DUMMY"

export INTEL_TH="intel_th"
export INTEL_TH_PCI="intel_th_pci"
export INTEL_TH_GTH="intel_th_gth"
export INTEL_TH_STH="intel_th_sth"
export INTEL_TH_MSU="intel_th_msu"
export INTEL_TH_PTI="intel_th_pti"

export INTEL_TH_KCONFIG="CONFIG_INTEL_TH"
export INTEL_TH_PCI_KCONFIG="CONFIG_INTEL_TH_PCI"
export INTEL_TH_GTH_KCONFIG="CONFIG_INTEL_TH_GTH"
export INTEL_TH_STH_KCONFIG="CONFIG_INTEL_TH_STH"
export INTEL_TH_MSU_KCONFIG="CONFIG_INTEL_TH_MSU"
export INTEL_TH_PTI_KCONFIG="CONFIG_INTEL_TH_PTI"
