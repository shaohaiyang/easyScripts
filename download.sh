#!/bin/sh
read STRING

LIMIT="1.2"
if [ ! -e /tmp/download.lock ];then
	LOAD=`uptime |awk -F"average:" '{print $2}'|cut -d, -f1`
	AVG=`cat /proc/cpuinfo |grep processor -c`
	AVG=`echo "scale=2;$AVG/$LIMIT" | bc -l`

        RESULT=`echo "$LOAD<$AVG"|bc`

	#RESULT="0"
        if [ $RESULT -eq 1 ];then
		METHOD=`echo $STRING | cut -d# -f1`
		URL=`echo $STRING | cut -d# -f2`
		URL="http://$URL"
		echo "$URL	#`date +%Y%m%d-%H%M%S`" >> /tmp/download.log

		case "$METHOD" in
       		 	php)
				curl -s $URL ;;
		esac
	else
		echo "load is $LOAD,higher than $AVG	#`date +%Y%m%d-%H%M%S`" >>  /tmp/download.log
	fi
fi
#SQL="select * from city_ip where province=\"$STRING\""
#echo "$TYPE     $SQL    `date`" >> aa
#mysql ip -B -e "$SQL"|sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g'|tr '100' 'aaa' > /var/www/html/result.csv
