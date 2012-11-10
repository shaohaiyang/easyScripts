#!/bin/sh
# added by geminis 2010/11/05
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg

ps -ef|grep -w gearman|grep -vq grep
if [ $? != 0 ];then
	nohup /opt/gearmand/bin/gearman -h 127.0.0.1 -w -f download -- /usr/bin/download.sh &
fi

ps -ef|grep -w "gearmand -d"|grep -vq grep
if [ $? != 0 ];then
	/etc/init.d/gearmand start
fi

[ -e /tmp/download.lock ] && find /tmp/download.lock -mmin +30|grep -q download
if [ $? = 0 ];then
	ps -auxf|grep http|grep R|awk '/http/{print $2}' | xargs kill -9 
	KEY=`cat /tmp/download.lock`
	if [ -x /usr/bin/mysql ];then
		MYSQL="mysql"
	else
		MYSQL="/usr/local/mysql/bin/mysql"
	fi
	
	$MYSQL -u$MYSQL_USER -p$MYSQL_PASS $DATABASE -e 'update download_job set status="X" where `key`="'$KEY'"'
	rm -rf /tmp/download.lock
	echo "$KEY      killed#`date +%Y%m%d-%H%M%S`" >> /tmp/download.log
fi

KEYS=$(sort -k1 /tmp/download.log | awk '/download/{print $1}'|uniq -c|awk '{if($1>3) {st=index($2,"key");print substr($2,st+4,32)}}')

for KEY in $KEYS;do
        if [ -x /usr/bin/mysql ];then
                MYSQL="mysql"
        else
                MYSQL="/usr/local/mysql/bin/mysql"
        fi

        $MYSQL -u$MYSQL_USER -p$MYSQL_PASS $DATABASE -e 'update download_job set status="XX" where `key`="'$KEY'"'
	echo "$KEY      Cancel#`date +%Y%m%d-%H%M%S`" >> /tmp/download.log
	sed -r -i "/$KEY/d" /tmp/download.log
done
