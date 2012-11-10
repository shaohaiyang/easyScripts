#!/bin/sh
CTC="/var/named/chroot/var/named/53kf.com.chinanet"
CNC="/var/named/chroot/var/named/53kf.com.cnc"

if [ -z "$1" -o -z "$2" ];then
	echo "$0 www1 ctc_proxy_ip cnc_proxy_ip"
	exit 0
else
	PIP1=$2
	PIP2=$3

	IP1=$(grep -w "$1[^0-9]" $CTC|awk '{print $4}')
	RIP1=$(grep -w "$1.r[^0-9]" $CTC|awk '{print $4}')
	IP2=$(grep -w "$1[^0-9]" $CNC|awk '{print $4}')
	RIP2=$(grep -w "$1.r[^0-9]" $CNC|awk '{print $4}')

	[ -z $RIP1 ] && RIP1=$IP1
	[ -z $RIP2 ] && RIP2=$IP2
	[ -z $PIP1 ] && PIP1=$RIP1
	[ -z $PIP2 ] && PIP2=$RIP2

	serial1=$(awk -F";" '/serial/{print $1}' $CTC)
	serial11=$((serial1+1))
	serial2=$(awk -F";" '/serial/{print $1}' $CNC)
	serial22=$((serial2+1))

	sed -r -i "s#$serial1#\t\t\t\t$serial11#g" $CTC
	sed -r -i "s#$serial2#\t\t\t\t$serial22#g" $CNC
	sed -r -i "/$1[^0-9]/d" $CTC
	sed -r -i "/$1[^0-9]/d" $CNC
	sed -r -i "/$1.r[^0-9]/d" $CTC
	sed -r -i "/$1.r[^0-9]/d" $CNC
	sed -r -i "/\*/i$1\t\tIN\tA\t$PIP1" $CTC
	sed -r -i "/\*/i$1.r\t\tIN\tA\t$RIP1" $CTC
	sed -r -i "/\*/i$1\t\tIN\tA\t$PIP2" $CNC
	sed -r -i "/\*/i$1.r\t\tIN\tA\t$RIP2" $CNC

	/etc/init.d/named restart
fi
