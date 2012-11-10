#!/bin/sh
LOG="/var/log/nginx/access.log"
ERR="/tmp/bad_web.log"

if [ -z "$*" ];then
	awk -F~ '{if($4!~/200/ && $4!~/304/ && $4!~/301/ && $4!~/302/) print $0}' $LOG  > $ERR
else
	for i in $@;do
		awk -F~ '{if($4~/'"$i"'/) print $0}' $LOG  > $ERR
	done
fi
