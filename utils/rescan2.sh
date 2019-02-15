#!/bin/sh

# get current PCI list

pcilist=$(lspci | grep Xilinx | awk '{ print $1 }')
echo $pcilist

# remove current PCI list
for pcibus in $pcilist
do
	echo "/sys/bus/pci/devices/0000:$pcibus/remove"
	echo 1 > /sys/bus/pci/devices/0000:$pcibus/remove
done

sleep 1

# rescan pci-e bus
echo "Listing Pci-E devices"
lspci | grep Xilinx

echo 1 > /sys/bus/pci/rescan
sleep 2

# enable PCI-e devices
# get rescaned PCI list

pcilist2=$(lspci | grep Xilinx | awk '{ print $1 }')
echo $pcilist2


for pcibus in $pcilist2
do
	echo "/sys/bus/pci/devices/0000:$pcibus/enable"
	echo 1 > /sys/bus/pci/devices/0000:$pcibus/enable
done

lspci | grep Xilinx

