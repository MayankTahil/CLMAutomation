#!/bin/bash
# ************************************************************
# Exports VM to a XVA template
# ************************************************************
# expecting input parameter: VM NAME in string format
#
# I.E.: VVMExport.sh <VM NAME> <MOUNTED_NFS_SHARE_DIR>
#		./VMExport.sh XDC-1 /mnt/storage

VMUUID=`xe vm-list | egrep -B1 $1 | grep uuid | sed -e 's/[^:]*: //' | grep -iv control`


FILENAME=$1".xva"

xe vm-export vm=$VMUUID filename=$2/$FILENAME