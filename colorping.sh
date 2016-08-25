#!/bin/bash

while true; do
	if ping -c 1 $1 > /dev/null; then
		echo -e "\e[92m$(date) - $2: $1 is ALIVE"
	else
		echo -e "\e[91m$(date) - $2: $1 is DEAD"
	fi
	sleep 1;
done
