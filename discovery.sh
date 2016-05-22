#!/bin/bash

source "$(dirname $0)/common.sh" || exit -1

disk_discovery() {
	echo -n '{"data":['
	for disk in $(ls -l /dev/disk/by-id/scsi-* | egrep -o '[a-z]+$')
	do
		echo -n "{\"{#DISK}\":\"$disk\"},"
	done
	
	echo -e '\b]}'
}


if [ -z "$1" ];then
	_error_exit
fi

command_name=$1
shift
case "$command_name" in
	disk_discovery)
		disk_discovery "$@";;
	help)
		cat <<HELP_END;;
disk_discovery
	It prints discovery json for all disks found in system, key is "#DISK"
HELP_END
	*)
		_error_exit;;
esac
