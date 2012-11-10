#!/bin/sh
# added by geminis 2010/11/05
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg

### check nginx status
curl -s http://115.236.19.67/nginxstatus > /tmp/nginx_status

### check mysql thread status
mysql -u$MYSQL_USER -p$MYSQL_PASS -e "show status like 'thread%' "|awk '/[0-9*]/{print $2}' > /tmp/.mysql
mv /tmp/.mysql /tmp/mysql_threads

### check online person status
JAVA="/opt/javaserver"
java -jar $JAVA/memcheck.jar |grep xml|sed -r "s#.*clientcount='(.*)' kfclientcount='(.*)' consultationcount='(.*)' webguestcount='(.*)' max.*aliveSession='(.*)' excutorActiveCount='(.*)' excutorPoolSize=.*#ClientCount\t\1\nKFClientCount\t\2\nTalkcount\t\3\nGuestCount\t\4\nAliveSession\t\5\nThreadNumber\t\6#g" > /tmp/.online
mv /tmp/.online /tmp/online_status

### check varnish status
#VARNISH="/opt/varnish"
#$VARNISH/bin/varnishstat -1 > /tmp/.varnish_log
#awk '{if($1~/^cache_hit$/){aa=$2} if($1~/cache_miss/) {print aa/(aa+$2)*100}}' /tmp/.varnish_log > /tmp/.varnish
#awk '{if($1~/^n_object$/ || $1~/n_expired/ || $1~/n_lru_nuked/ || $1~/n_lru_moved/) {print $2}}' /tmp/.varnish_log >> /tmp/.varnish
#mv /tmp/.varnish /tmp/varnish_log

### check php daemon alive
find $PHP_DAEMON_LOG/php-daemon.log -mmin -5|grep -q php
if [ $? != 0 ];then
	/etc/init.d/php-daemon restart
	echo `date` "daemon restart." >> $PHP_DAEMON_LOG/php-daemon.info
fi

### check ddos attack ,release after some time
RELOAD="no"
CONF="/opt/nginx/conf/stoplist /opt/nginx/conf/blacklist"
for file in $CONF;do
	if [ -s $file ];then
		TIME=`date +%s`
		while read LINE;do
			LINE=`echo "$LINE"|awk -F# '{print $2}'`
			START=`echo $LINE|cut -d@ -f1`
			LONG=`echo $LINE|cut -d@ -f2`
			R=`echo "$TIME-$START-$LONG"|bc`
			if [ $R -gt 0 ];then
				RELOAD="yes"
				sed -r -i "/$START/d" $file
			fi
		done < $file
		if [ $RELOAD = "yes" ];then
			/usr/bin/block_guest_nginx.sh
			/usr/bin/block_referer_nginx.sh
		fi
	fi
done
[ $RELOAD = "yes" ] && /etc/init.d/nginx reload
