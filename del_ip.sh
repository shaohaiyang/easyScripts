#!/bin/sh
if [ ! -z $1 ];then
	for i in $@;do
		NUM=`iptables -vn -t nat -L PREROUTING|grep $i|wc -l`
		for j in `seq 1 $NUM`;do
			ID=`iptables -vn -t nat -L PREROUTING --line-number|grep $i|awk '{print $1}'|head -n1`
			iptables -t nat -D PREROUTING $ID
			echo "$i id:$ID was unblocked."
		done
		sed -r -i "/$i/d" /etc/bad_ip
	done
	iptables-save > /opt/firewall_rules
else 
	echo "$0 xxx.xxx.xxx.xxx xxx.xxx.xxx.xxx"
fi

