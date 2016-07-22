#!/bin/bash
# ************************************************************
# Checks if VM is ON or OFF on XenServer Host, and if ON, it will turn the VM off without user promp or confirmation
# ************************************************************
# expecting input parameter: VM NAME in string format
#
# I.E.: VMState.sh <VM NAME>
#		./VMState.sh XDC-1 
 
VMUUID=`xe vm-list | egrep -B1 $1 | grep uuid | sed -e 's/[^:]*: //' | grep -iv control`


# Allow the path to the environment variable
if [ -z "${XE}" ]; then 
	XE=xe
fi

# Check the power state of the vm
name=$(${XE} vm-list uuid=$VMUUID params=name-label --minimal)
state=$(${XE} vm-list uuid=${VMUUID} params=power-state --minimal)

# If the VM state is running, we shutdown the vm first
if [ "${state}" = "running" ]; then
	${XE} vm-shutdown uuid=${VMUUID}
	${XE} event-wait class=vm power-state=halted uuid=${VMUUID}
	exit 0 
fi

exit 0