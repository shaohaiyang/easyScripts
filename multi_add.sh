#!/bin/sh
. /etc/53kf.cfg

if [ ! -z "$PROXY_HOST" ];then
	for i in $PROXY_HOST;do
		NAME=`echo $i|cut -d@ -f1`
		IP=`echo $i|cut -d@ -f2`
		proxy_add.sh $NAME $IP
	done
fi
