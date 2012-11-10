#!/bin/sh
IPTABLE_RULES="/opt/firewall_rules"
FILE="/etc/bad_ip"
IPTABLE="/sbin/iptables"

if [ -s $IPTABLE_RULES ];then
	iptables-restore < $IPTABLE_RULES	
else
	$IPTABLE -t nat -L PREROUTING -n > /tmp/rules.tmp
	if [ -s $FILE ];then
		while read IP;do
       		 	grep -q $IP /tmp/rules.tmp
       		 	[ $? = 1 ] && $IPTABLE -t nat -I PREROUTING -s $IP -j DROP
		done < $FILE
	fi
fi
