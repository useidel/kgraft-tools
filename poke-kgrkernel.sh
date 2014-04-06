#!/bin/sh
PATH=/bin:/usr/bin:/usr/local/bin
export PATH
MYUID=`id -u`

if [ ! $MYUID -eq 0 ]; then
	echo
	echo " Run as root user"
	echo
	exit 1
else
	for i in `dmesg |grep 'still in kernel after timeout' | awk '{print $4}' |sort -u`
	do 
		kill -USR1 $i
	done
fi
