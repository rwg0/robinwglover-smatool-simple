#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin
while [ 1 ]
do
	hciconfig hci0 up
	sleep 10
	hcitool scan
	./smatool -l
	RES=$?
	if [ $RES -eq 32 ]; then exit 32; fi
	hciconfig hci0 down
	sleep 10

done
