#!/bin/bash
##############################################
#  (c) Intel Corporation 2013                #
#                                            #
#  Author: Yann Argotti                      #
#  Contributors: Christophe Prigent          #
#                Jerome Blin                 #
#                Christophe Coquard          #
#                Sebastien Dufour            #
#                Jean-Christhope Iaccono     #
#                                            #
#  Version: 0.5                              #
##############################################

#---------------------------------------#
# Extract measures and convert to msecs #
#---------------------------------------#
extract_time () {
    measured_time=$(echo $measures | awk '{print $('$1')}')
    if [[ $(echo $units | awk '{print $('$1')}') =~ "usecs" ]]; then
      measured_time=$(echo "scale=3; $measured_time/1000" |bc -l)
    fi
    echo $measured_time
}

# load config file if exist
if [[ -e kpi_config ]]; then
  . kpi_config
else
  build_date="11/27/14"
  measure_date=$(date +%D)
  invalid_time="NA"
  DEBUG=
fi

# First do a suspend to RAM and resume 
#  1. Execute commands: 
#   sudo -s
#   echo mem > /sys/power/state
#  2. Wait 30 seconds
#  3. Resume with keyboard or power button

# unbind audio devices
#su -c 'echo 0000:00:1b.0 > /sys/bus/pci/drivers/snd_hda_intel/unbind'
#su -c 'echo 0000:00:03.0 > /sys/bus/pci/drivers/snd_hda_intel/unbind'


#----------------------#
# main processing loop #
#----------------------#
# Display help
	if [ "$1" == "--help" ]; then
	    echo -e "
	    \t Usage: `basename $0` directory
	    \t Exemple: ./get_measures kpi_bsw/	
	    \t --help           \t print this help menu"
	    exit 0
	fi

# Then for each kpi definition proceed on data extraction
for f in $1/*kpi
do
  if [[ -n $DEBUG ]]; then echo $f ; fi
  old_IFS=$IFS
  cat $f | while IFS=' ' read jira_code measure_mode mod_name data1 data2 data3 data4
  do
    case "$measure_mode" in
      b)
	 if [[ -n $DEBUG ]]; then echo "Initcall mode at boot time" ; fi
         #Retrieve log (include measures and time units) takes 1st one
  	 log=$(dmesg | grep -E "initcall $mod_name.* returned 0")
         if [[ -z $log ]]; then
           initcall_time=$invalid_time
         else
           measures=$(echo $log |grep -Po '(?<=after )[[:digit:]]*.[[:digit:]]*')
           units=$(echo $log |grep -Eo '([^&]secs)')
	   #Extract measure
           initcall_time=$(extract_time "1")
         fi
    	 echo "$jira_code, $initcall_time, $measure_date, $mod_name, initcall-boot, $f"
         ;;

      i)
	 if [[ -n $DEBUG ]]; then echo "Initcall mode" ; fi
         #Retrieve log (include measures and time units) takes last one
  	 log=$(dmesg | grep -E "initcall $mod_name.* returned 0" |tail -1)
         if [[ -z $log ]]; then
           initcall_time=$invalid_time
         else
           measures=$(echo $log |grep -Po '(?<=after )[[:digit:]]*.[[:digit:]]*')
           units=$(echo $log |grep -Eo '([^&]secs)')
	   #Extract measure
           initcall_time=$(extract_time "1")
         fi
    	 echo "$jira_code, $initcall_time, $measure_date, $mod_name, initcall, $f"
         ;;

      ilu|I) 
         if [[ -n $DEBUG ]]; then echo "Initcall mode with load / unload (insmod)" ; fi
  	 init_nb_before=$(dmesg | grep -cE "initcall $mod_name.* returned 0")
         pwd=$PWD
	 # Change directory depending on the kernel object
  	 if [ "$mod_name" = "int3400_thermal" ] || [ "$mod_name" = "int3403_thermal" ]
	 then 
		cd /lib/modules/$(uname -r)/kernel/drivers/thermal/int340x_thermal;
	 elif [ "$mod_name" = "intel_powerclamp" ] || [ "$mod_name" = "intel_soc_dts_thermal" ] || [ "$mod_name" = "x86_pkg_temp_thermal" ]
	 then
    		cd /lib/modules/$(uname -r)/kernel/drivers/thermal;
	 else
    		cd /lib/modules/$(uname -r)/kernel/drivers/;
	 fi
         # start with unload
	 if [[ -n $data1 ]]; then
           sudo rmmod $data1 2> /dev/null
         fi
	 if [[ -n $data2 ]]; then
           sudo rmmod $data2 2> /dev/null
         fi
	 if [[ -n $data3 ]]; then
           sudo rmmod $data3 2> /dev/null
         fi
	 if [[ -n $data4 ]]; then
           sudo rmmod $data4 2> /dev/null
         fi
         # continue with load
	 if [[ -n $data4 ]]; then
           sudo insmod $data4 2> /dev/null
         fi
	 if [[ -n $data3 ]]; then
           sudo insmod $data3 2> /dev/null
         fi
	 if [[ -n $data2 ]]; then
           sudo insmod $data2 2> /dev/null
         fi
	 if [[ -n $data1 ]]; then
           sudo insmod $data1 2> /dev/null
         fi
         cd $pwd
  	 init_nb_after=$(dmesg | grep -cE "initcall $mod_name.* returned 0")
         #Retrieve log (include measures and time units)takes last one
  	 log=$(dmesg | grep -E "initcall $mod_name.* returned 0" |tail -1)
         if [[ -z $log ]]; then
           initcall_time=$invalid_time
         elif [[ $init_nb_before == $init_nb_after ]] ; then
           initcall_time=$invalid_time
         else
           measures=$(echo $log |grep -Po '(?<=after )[[:digit:]]*.[[:digit:]]*')
           units=$(echo $log |grep -Eo '([^&]secs)')
	   #Extract measure
           initcall_time=$(extract_time "1")
         fi
    	 echo "$jira_code, $initcall_time, $measure_date, $mod_name, inicall+ins, $f"
         ;;

      m)
	 if [[ -n $DEBUG ]]; then echo "Initcall mode with load / unload (modprobe)" ; fi
  	 init_nb_before=$(dmesg | grep -cE "initcall $mod_name.* returned 0")
         pwd=$PWD
	 # Change directory depending on the kernel object
  	 if [ "$mod_name" = "int3400_thermal" ] || [ "$mod_name" = "int3403_thermal" ]
	 then 
		cd /lib/modules/$(uname -r)/kernel/drivers/thermal/int340x_thermal;
	 elif [ "$mod_name" = "intel_powerclamp" ] || [ "$mod_name" = "intel_soc_dts_thermal" ] || [ "$mod_name" = "x86_pkg_temp_thermal" ]
	 then
    		cd /lib/modules/$(uname -r)/kernel/drivers/thermal;
	 else
    		cd /lib/modules/$(uname -r)/kernel/drivers/;
	 fi
         # start with unload
	 if [[ -n $data1 ]]; then
           sudo modprobe -r $data1 2> /dev/null
         fi
	 if [[ -n $data2 ]]; then
           sudo modprobe -r $data2 2> /dev/null
         fi
	 if [[ -n $data3 ]]; then
           sudo modprobe -r $data3 2> /dev/null
         fi
	 if [[ -n $data4 ]]; then
           sudo modprobe -r $data4 2> /dev/null
         fi
         # continue with load
	 if [[ -n $data4 ]]; then
	   sleep 0.1	
           sudo modprobe $data4 2> /dev/null
         fi
	 if [[ -n $data3 ]]; then
           sleep 0.1
           sudo modprobe $data3 2> /dev/null
         fi
	 if [[ -n $data2 ]]; then
           sleep 0.1
           sudo modprobe $data2 2> /dev/null
         fi
	 if [[ -n $data1 ]]; then
           sleep 0.1
           sudo modprobe $data1 2> /dev/null
         fi
         cd $pwd
  	 init_nb_after=$(dmesg | grep -cE "initcall $mod_name.* returned 0")
         #Retrieve log (include measures and time units)takes last one
  	 log=$(dmesg | grep -E "initcall $mod_name.* returned 0" |tail -1)
         if [[ -z $log ]]; then
           initcall_time=$invalid_time
         elif [[ $init_nb_before == $init_nb_after ]] ; then
           initcall_time=$invalid_time
         else
           measures=$(echo $log |grep -Po '(?<=after )[[:digit:]]*.[[:digit:]]*')
           units=$(echo $log |grep -Eo '([^&]secs)')
	   #Extract measure
           initcall_time=$(extract_time "1")
         fi
    	 echo "$jira_code, $initcall_time, $measure_date, $mod_name, initcall+mod, $f"
         ;;

      s|S)
	 if [[ -n $DEBUG ]]; then echo "Suspend mode" ; fi
         #Retrieve log (include measures and time units) takes last ones
	 log=$(dmesg | grep -E "(call .*$mod_name\+ returned 0 after)" |tail -4)
#  	 log=$(dmesg | grep -E "(PM:.*complete|$mod_name.*\+ returned)" |tail -4)
         if [[ -n $log && -n $(echo $log | grep $mod_name) ]]; then
           measures=$(echo $log |grep -Po '(?<=after )[[:digit:]]*.[[:digit:]]*')
           units=$(echo $log |grep -Eo '([^&]secs)')
	   #Extract measure#Extract measures: number of data to consider can vary
           if [[ $(echo $measures | wc -w) > 2 ]]; then
             suspend1=$(extract_time "1")
             suspend2=$(extract_time "2")
           else
             suspend1=$(extract_time "1")
           fi
           # verify returned value validity
	   if [[ -z $suspend1 ]]; then
              suspend_time=$invalid_time
           elif [[ -z $suspend2 ]]; then
              suspend_time=$suspend1
           else
 	     suspend_time=$(echo $suspend1+$suspend2 |bc)
	   fi
         else
           suspend_time=$invalid_time
         fi
    	 echo "$jira_code, $suspend_time, $measure_date, $mod_name, suspend, $f"
         ;;

      r|R)
	 if [[ -n $DEBUG ]]; then echo "Resume mode" ; fi
         #Retrieve log (include measures and time units) takes last ones
 	 log=$(dmesg | grep -E "(call .*$mod_name\+ returned 0 after)" |tail -4)
# 	 log=$(dmesg | grep -E "(PM:.*complete|$mod_name.*\+ returned)" |tail -4)
         if [[ -n $log && -n $(echo $log | grep $mod_name) ]]; then
           measures=$(echo $log |grep -Po '(?<=after )[[:digit:]]*.[[:digit:]]*')
           units=$(echo $log |grep -Eo '([^&]secs)')
	cnt=$(echo $measures | wc -l)
	   #Extract measure#Extract measures: number of data to consider can vary
           if [[ $(echo $measures | wc -w) > 2 ]]; then
	     resume1=$(extract_time "3")
	     resume2=$(extract_time "4")
           else
	     resume1=$(extract_time "2")
           fi
           # verify returned value validity
	   if [[ -z $resume1 ]]; then
              resume_time=$invalid_time
           elif [[ -z $resume2 ]]; then
              resume_time=$resume1
           else
  	     resume_time=$(echo $resume1+$resume2 |bc)
	   fi
         else
           resume_time=$invalid_time
         fi
    	 echo "$jira_code, $resume_time, $measure_date, $mod_name, resume, $f"
         ;;

      *)
	 if [[ -n $DEBUG ]]; then echo "unknown mode" ; fi
    esac
  done
  IFS=$old_IFS
done
