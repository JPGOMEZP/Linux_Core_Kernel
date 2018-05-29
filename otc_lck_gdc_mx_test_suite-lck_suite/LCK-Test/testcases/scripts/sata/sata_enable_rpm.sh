#!/bin/bash
 
# Max every 10 minutes flush dirty pages
FLUSH=600
TIMEOUT=${1:-15}
HOST=$(lspci -D | grep "SATA controller" | cut -f 1 -d ' ')
DISK=sda
 
# See Documentation/laptops/laptop-mode.txt for more information about the
# following tunables.
echo $((FLUSH * 100)) > /proc/sys/vm/dirty_writeback_centisecs
echo $((FLUSH * 100)) > /proc/sys/vm/dirty_expire_centisecs
# Enable laptop mode
echo 5 > /proc/sys/vm/laptop_mode
 
# Enable runtime PM for all ports
for port in /sys/bus/pci/devices/$HOST/ata*; do
         echo auto > $port/power/control
done
# The for the host
echo auto > /sys/bus/pci/devices/$HOST/power/control
 
# And last for the disk
echo auto > /sys/block/$DISK/device/power/control
echo $(($TIMEOUT * 1000)) > /sys/block/$DISK/device/power/autosuspend_delay_ms
