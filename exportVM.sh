#!/bin/bash
#
#
# 1: ssh into XS Host from connector
# 2: mount cloud storage repository
# 3: Check to see if VM is on or off. If the VM is on, turn it off 
# 4: export VM to template saved in cloud repository
# 5: unmount the repository 
# I.E. ./exportVM.sh <VMNAME> <XEN_USERNAME> <XENHOST_IP> <NFS_SHARE_IP>
# I.E: ./exportVM.sh TESTVM admin 192.168.0.30 192.168.0.26

VMNAME=$1
XENUSER=$2
XENHOST=$3
NFSHOST=$4

#VMUUID=`xe vm-list | egrep -B1 $VMNAME | grep uuid | sed -e 's/[^:]*: //' | grep -iv control`

# 2: mount cloud NFS storage repository
NFS_SHARE="/mnt/storage"

### --TODO-- Check if directory is already mounted
ssh $XENUSER@$XENHOST "mkdir -p $NFS_SHARE && mount $NFSHOST:/var/nfs $NFS_SHARE"

# 3: Check to see if VM is on or off: If the VM is on, turn it off 
ssh root@$XENHOST "bash -s" -- < ./VMState.sh $VMNAME
echo "\n\n VM has been turned off\n\n"


# 4: export VM to template saved in cloud repository
echo "About to export, this may take some time..."
ssh root@$XENHOST "bash -s" -- < ./VMExport.sh $VMNAME $NFS_SHARE

# 5: unmount the repository 
ssh root@$XENHOST "umount $NFS_SHARE"