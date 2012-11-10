#!/bin/sh
IP=`echo "$1"|awk '{print $1}'`
NUM=`echo "$1"|awk '{print $2}'`
STATE=`echo "$1"|awk '{print $3}'`
LIMIT=`echo "$1"|awk '{print $4}'`

LOG_ALL=0

if [ $NUM -ge $LIMIT ];then
        printf "* %-20s\t%-4s\t%-15s\t%s\t%s\n" $IP $NUM $STATE `date +%H:%M:%S-%m/%d/%Y` `date -d "now" +%s` >> /var/log/ddos_ip.log
        echo $IP >> /etc/blacklist.txt
        iptables -L wblist-chain -n |grep -q $IP
        [ $? = 1 ] && iptables -I wblist-chain -s $IP -j DROP
elif [ $LOG_ALL = 1 ];then
        printf "%-20s\t%-4s\t%-15s\t%s\t%s\n" $IP $NUM $STATE `date +%H:%M:%S-%m/%d/%Y` `date -d "now" +%s`  >> /var/log/ddos_ip.log
fi

