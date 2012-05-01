#!/bin/sh

while [ 1 ]
do
	netcat -l -e "sh /root/smamon.sh /sh" -p 1100
done
