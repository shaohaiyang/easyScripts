#!/bin/bash                                                                                        
NIC=eth0
RED_COLOR="\\033[1;31m"  # red color
GRE_COLOR="\\033[32;1m"  # green color
NOR_COLOR="\\033[0;39m"  # normal color

while : ; do
        time=`date +%Y/%m/%d" "%k":"%M":"%S`
	net_flood=`ifconfig $NIC|sed -n "8"p`
        rx_before=`echo $net_flood|awk '{print $2}'|cut -c7-`
        tx_before=`echo $net_flood|awk '{print $6}'|cut -c7-`
        sleep 2
	net_flood=`ifconfig $NIC|sed -n "8"p`
        rx_after=`echo $net_flood|awk '{print $2}'|cut -c7-`
        tx_after=`echo $net_flood|awk '{print $6}'|cut -c7-`
        rx_result=$[(rx_after-rx_before)/2]
        tx_result=$[(tx_after-tx_before)/2]
        echo -n $time
	echo -e $GRE_COLOR In_Speed: "$rx_result" bps $RED_COLOR Out_Speed: "$tx_result" bps $NOR_COLOR
        sleep 2
done
