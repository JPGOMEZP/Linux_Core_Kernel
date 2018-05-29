#!/bin/bash

extract_time() {
  MEASURED_TIME=$(echo $MEASURES | awk '{print $('$1')}')
  if [[ $(echo $UNITS | awk '{print $('$1')}') =~ "usecs" ]]; then
    MEASURED_TIME=$(echo "scale=3; $MEASURED_TIME/1000" | bc -l)
  fi
  echo $MEASURED_TIME
}


KERNEL_VERSION=$(uname -r)
MEASURE_DATE=$(date +%D)
INVALID_TIME="NA"
DEBUG=""

echo "Kernel: ${KERNEL_VERSION}"
echo "Date: ${MEASURE_DATE}"

for f in $1/*kpi; do
  if [[ -n "${DEBUG}" ]]; then echo "${f}"; fi

  old_IFS=$IFS
  echo "-------------------------------------------------------"
  cat "${f}" | while IFS=' ' read JIRA_CODE MEASURE_MODE KMOD_NAME DATA1 DATA2 DATA3 DATA4; do
    case "${MEASURE_MODE}" in
      b) if [[ -n "${DEBUG}" ]]; then echo "Initcall mode at boot time"; fi
         LOG=$(dmesg | grep -E "initcall ${KMOD_NAME}.* returned 0")
         if [ -z "${LOG}" ]; then
           INITCALL_TIME="${INVALID_TIME}"
         else
           MEASURES=$(echo "${LOG}" | grep -Po '(?<=after )[[:digit:]]*.[[:digit:]]*')
           UNITS=$(echo "${LOG}" | grep -Eo '([^&]secs)')
           INITCALL_TIME=$(extract_time "1")
         fi
         printf "%-6s At boot \t%-25s \t%-3.3f\n" "${JIRA_CODE}" "${KMOD_NAME}" "${INITCALL_TIME}"
         ;;
      i) if [[ -n $DEBUG ]]; then echo "Initcall mode"; fi
         LOG=$(dmesg | grep -E "initcall $KMOD_NAME.* returned 0" | tail -1)
         if [ -z "${LOG}" ]; then
           INITCALL_TIME="${INVALID_TIME}"
         else
           MEASURES=$(echo "${LOG}" | grep -Po '(?<=after )[[:digit:]]*.[[:digit:]]*')
           UNITS=$(echo "${LOG}" | grep -Eo '([^&]secs)')
           INITCALL_TIME=$(extract_time "1")
         fi
         printf "%-6s Init \t%-25s \t%-3.3f\n" "${JIRA_CODE}" "${KMOD_NAME}" "${INITCALL_TIME}"
         ;;
      m) if [[ -n $DEBUG ]]; then echo "Initcall mode with load / unload (modprobe)"; fi
         INIT_NB_BEFORE=$(dmesg | grep -cE "initcall $KMOD_NAME.* returned 0")
         pwd=$PWD

         if [ "${KMOD_NAME}" = "int3400_thermal" ] || [ "${KMOD_NAME}" = "int3403_thermal" ]; then
           cd /lib/modules/$(uname -r)/kernel/drivers/thermal/int340x_thermal;
         elif [ "${KMOD_NAME}" = "intel_powerclamp" ] || [ "${KMOD_NAME}" = "intel_soc_dts_thermal" ] || [ "${KMOD_NAME}" = "x86_pkg_temp_thermal" ]; then
           cd /lib/modules/$(uname -r)/kernel/drivers/thermal;
         else
           cd /lib/modules/$(uname -r)/kernel/drivers/;
         fi

         if [ -n "${DATA1}" ]; then
           sudo modprobe -r "${DATA1}" 2> /dev/null
         fi
         if [ -n "${DATA2}" ]; then
           sudo modprobe -r "${DATA2}" 2> /dev/null
         fi
         if [ -n "${DATA3}" ]; then
           sudo modprobe -r "${DATA3}" 2> /dev/null
         fi
         if [ -n "${DATA4}" ]; then
           sudo modprobe -r "${DATA4}" 2> /dev/null
         fi

         if [ -n "${DATA4}" ]; then
           sleep 0.1
           sudo modprobe "${DATA4}" 2> /dev/null
         fi
         if [ -n "${DATA3}" ]; then
           sleep 0.1
           sudo modprobe "${DATA3}" 2> /dev/null
         fi
         if [ -n "${DATA2}" ]; then
           sleep 0.1
           sudo modprobe "${DATA2}" 2> /dev/null
         fi
         if [ -n "${DATA1}" ]; then
           sleep 0.1
           sudo modprobe "${DATA1}" 2> /dev/null
         fi
         cd $pwd

         INIT_NB_AFTER=$(dmesg | grep -cE "initcall ${KMOD_NAME}.* returned 0")
         LOG=$(dmesg | grep -E "initcall ${KMOD_NAME}.* returned 0" | tail -1)
         if [ -z "${LOG}" ]; then
           INITCALL_TIME="${INVALID_TIME}"
         elif [ "${INIT_NB_BEFORE}" == "${INIT_NB_AFTER}" ]; then
           INITCALL_TIME="${INVALID_TIME}"
         else
           MEASURES=$(echo "${LOG}" | grep -Po '(?<=after )[[:digit:]]*.[[:digit:]]*')
           UNITS=$(echo "${LOG}" | grep -Eo '([^&]secs)')
           INITCALL_TIME=$(extract_time "1")
         fi
         printf "%-6s Load \t%-25s \t%-3.3f\n" "${JIRA_CODE}" "${KMOD_NAME}" "${INITCALL_TIME}"
         ;;
      s) if [ -n "${DEBUG}" ]; then echo "Suspend mode"; fi
         LOG=$(dmesg | grep -E "(call .*${KMOD_NAME}\+ returned 0 after)" | tail -4)
         if [[ -n "${LOG}" && -n $(echo "${LOG}" | grep "${KMOD_NAME}") ]]; then
           MEASURES=$(echo "${LOG}" | grep -Po '(?<=after )[[:digit:]]*.[[:digit:]]*')
           UNITS=$(echo "${LOG}" | grep -Eo '([^&]secs)')
           CNT=$(echo "${MEASURES}" | wc -l)

           if [[ $(echo "${MEASURES}" | wc -w) > 2 ]]; then
             SUSPEND1=$(extract_time "1")
             SUSPEND2=$(extract_time "2")
           else
             SUSPEND1=$(extract_time "1")
           fi

           if [[ -z "${SUSPEND1}" ]]; then
             SUSPEND_TIME="${INVALID_TIME}"
           elif [[ -z "${SUSPEND2}" ]]; then
             SUSPEND_TIME="${SUSPEND1}"
           else
             SUSPEND_TIME=$(echo "${SUSPEND1}"+"${SUSPEND2}" | bc)
           fi
         else
           SUSPEND_TIME="${INVALID_TIME}"
         fi
         printf "%-6s Suspend \t%-25s \t%-3.3f\n" "${JIRA_CODE}" "${KMOD_NAME}" "${SUSPEND_TIME}"
         ;;
      r) if [[ -n $DEBUG ]]; then echo "Resume mode"; fi
         LOG=$(dmesg | grep -E "(call .*${KMOD_NAME}\+ returned 0 after)" | tail -4)
         if [[ -n "${LOG}" && -n $(echo "${LOG}" | grep "${KMOD_NAME}") ]]; then
           MEASURES=$(echo "${LOG}" | grep -Po '(?<=after )[[:digit:]]*.[[:digit:]]*')
           UNITS=$(echo "${LOG}" | grep -Eo '([^&]secs)')
           CNT=$(echo "${MEASURES}" | wc -l)
           if [[ $(echo "${MEASURES}" | wc -w) > 2 ]]; then
             RESUME1=$(extract_time "3")
             RESUME2=$(extract_time "4")
           else
             RESUME1=$(extract_time "2")
           fi

           if [[ -z "${RESUME1}" ]]; then
               RESUME_TIME="${INVALID_TIME}"
           elif [[ -z "${RESUME2}" ]]; then
               RESUME_TIME="${RESUME1}"
           else
              RESUME_TIME=$(echo "${RESUME1}"+"${RESUME2}" | bc)
           fi
         else
           RESUME_TIME="${INVALID_TIME}"
         fi
         printf "%-6s Resume \t%-25s \t%-3.3f\n" "${JIRA_CODE}" "${KMOD_NAME}" "${RESUME_TIME}"
         ;;
      *) if [[ -n $DEBUG ]]; then echo "unknown mode" ; fi
    esac
  done
done
