#!/bin/sh
PRIO="-18"

if [ -z $1 ] ;then
	time="120"
else
	time=$1
fi

ps -ef|grep get_bad_get|grep -vq grep
if [ $? = 0 ];then
	kill -9 `pidof watch`
fi
nohup watch -n $time /usr/bin/get_bad_get.sh &
sleep 1
renice $PRIO `pidof watch`
