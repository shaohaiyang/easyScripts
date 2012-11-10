#!/bin/sh
IPTABLE="iptables"
FILE="$1.ip"
WHITE_IP="122.226.84.51"

awk '{print $3}' $1|sed -r -e '/b/d' -e '/^$/d'> $FILE

$IPTABLE -t nat -L PREROUTING -n > /tmp/rules.tmp

for wip in $WHITE_IP;do
	echo $wip >> /tmp/rules.tmp
done

if [ -s $FILE ];then
	while read IP;do
		grep -q $IP /tmp/rules.tmp
		[ $? = 1 ] && echo $IP && $IPTABLE -t nat -I PREROUTING -s $IP -j DROP
	done < $FILE
fi

cat $1 >> $1.log
