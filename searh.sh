#!/bin/bash
# ************************************************************
# search.sh - Citrix Consulting 4-19-13
# ************************************************************
# Searches for UUID or Name-Label of VM
# ************************************************************

declare -i DEBUG=0
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

function search-namelabel-comma() #finds vm-uuid based on namelabel
{
	VMS=$1
	VMS="(${VMS//,/|})" #replace commas with | for egrep command below
	VM_UUIDS=`xe vm-list | egrep -B1 $VMS | grep uuid | sed -e 's/[^:]*: //' | grep -iv control`
	
	for VM_UUID in $VM_UUIDS; do
		echo $VM_UUID
	done
	check_exit
	exit 0
}

function search-uuid2name() #finds namelabel based on comma separated uuids
{
	VMS=$1
	VMS="(${VMS//,/|})" #replace commas with | for egrep command below
	VM_NAMELABELS=`xe vm-list | egrep -A1 $VMS | grep name-label | sed -e 's/[^:]*: //'`
	
	for VM_NAMELABEL in $VM_NAMELABELS; do
		echo $VM_NAMELABEL
	done
	check_exit
	exit 0
}

function search-mac() #finds UUID based on comma separated MAC Addresses of VIF
{
	MACS=$1
	MACS="(${MACS//,/|})" #replace commas with | for egrep command below
	VM_UUIDS=`xe vif-list params=vm-uuid,MAC | egrep -B1 $MACS | grep uuid | sed -e 's/[^:]*: //' | grep -iv control`
		
	for VM_UUID in $VM_UUIDS; do
		echo $VM_UUID
	done
	check_exit
	exit 0
}

function check_exit()
{
	if [ $? -gt 0 ]; then
		echo "An error has occurred, exiting."
		exit 1
	fi
}

#command line arguments
opt="$1"
while [ ! -z "$opt" -a -z "${opt##-*}" ]; do
  opt=${opt#-}
  case "$opt" 
  	in
	-debug) #enable debug mode
		DEBUG=1; 
		echo -e $COL_MAGENTA"Debugging is enabled."$COL_RESET;
		;;
	mac) #mac search
		if echo $2 | grep -e ^- > /dev/null; then echo "Missing Argument: $1"; exit 1; fi
		if [ $DEBUG = 1 ]; then echo -e "Running MAC to VM-UUID";fi
		INPUT="$2";
		search-mac $INPUT
		shift;;
	uuid) #uuid to namelabel
		if echo $2 | grep -e ^- > /dev/null; then echo "Missing Argument: $1"; exit 1; fi
		if [ $DEBUG = 1 ]; then echo -e "Running VM-UUID to NameLabel";fi
		INPUT="$2";
		search-uuid2name $INPUT
		shift;;
	namelabel) #namelabel to vm-uuid
		if echo $2 | grep -e ^- > /dev/null; then echo "Missing Argument: $1"; exit 1; fi
		if [ $DEBUG = 1 ]; then echo -e "Running NameLabel to VM-UUID";fi
		INPUT="$2";
		search-namelabel-comma $INPUT
		shift;;
	h|-help)
		echo "Usage: $0 [-mac <mac(s)>] [-uuid <uuid(s)>] [-namelabel <namelabel(s)>]";
		echo "	-mac		Search for a VM-UUID based on a Mac Address (comma separated ex:aa:bb:cc:dd:ee:ff,11:22:33:44:55:66)";
		echo "	-uuid		Search for a NameLabel based on a VM-UUID (comma separated ex:VM-UUID,VM-UUID1)";
		echo "	-namelabel	Search for a VM-UUID based on a NameLabel (comma separated ex:NameLabel,NameLabel1)";
		echo "";
		exit 1;;
	*) echo "Unknown option -$opt !" ; exit 1;;
  esac
  shift
  opt="$1"
done
