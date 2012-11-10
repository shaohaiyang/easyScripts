#!/bin/sh
# added by geminis 2010/11/05
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg

LIMIT="1.2"

if [ ! -e /tmp/download.lock ];then
	LOAD=`uptime |awk -F"average:" '{print $2}'|cut -d, -f1`
	AVG=`cat /proc/cpuinfo |grep processor -c`
	AVG=`echo "scale=2;$AVG/$LIMIT" | bc -l`

        RESULT=`echo "$LOAD<$AVG"|bc`

	if [ -x /usr/bin/mysql ];then
		MYSQL="mysql"
	else
		MYSQL="/usr/local/mysql/bin/mysql"
	fi

        if [ $RESULT -eq 1 ];then
		$MYSQL -u$MYSQL_USER -p$MYSQL_PASS $DATABASE -e "select request_uri from download_job where status='n' limit 1 \G;"|awk '/request_uri/{print "http://"$2}' > /tmp/tasklist

		while read LINE;do
                	echo "$LINE      crond#`date +%Y%m%d-%H%M%S`" >> /tmp/download.log
			curl -s $LINE
		done < /tmp/tasklist

        else
		$MYSQL -u$MYSQL_USER -p$MYSQL_PASS -e "show processlist" |grep -v Sleep > /tmp/processlist_`date +%Y%m%d-%H%M%S`
                echo "load is $LOAD,higher than $AVG    crond#`date +%Y%m%d-%H%M%S`" >>  /tmp/download.log
	fi
fi
