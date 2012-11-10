#!/bin/sh
allow(){
	echo "1" > /proc/sys/net/ipv4/ip_forward
	sed -r -i 's:ip_forward.*:ip_forward = 1:g' /etc/sysctl.conf
        iptables -L -vn -t nat|grep -q MASQ
        [ $? = 0 ] || iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -p ALL -j MASQUERADE
}
deny(){
	echo "0" > /proc/sys/net/ipv4/ip_forward
	sed -r -i 's:ip_forward.*:ip_forward = 0:g' /etc/sysctl.conf
	iptables -F -t nat
	iptables -X -t nat
}

case $1 in
	allow)
		allow;;
	deny)
		deny;;
	*)
		echo "$0 { allow|deny }"
		exit 0;;
esac
