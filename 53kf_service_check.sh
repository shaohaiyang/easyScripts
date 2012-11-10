#!/bin/sh
SERVICES="nginx php-fpm javacomet gearmand mysqld memcached sshd zabbix_agentd php-daemon keepalived haproxy varnish"
TABLES=""

### Color setting
RED_COL="\\033[1;31m"  # red color
GREEN_COL="\\033[32;1m"     # green color
BLUE_COL="\\033[34;1m"    # blue color
YELLOW_COL="\\033[33;1m"         # yellow color
NORMAL_COL="\\033[0;39m"

for i in $SERVICES;do
        echo $i|grep -q "^#"
        if [ $? != 0 ] ;then
		j=$i
		[ $i = "javacomet" ] && j="java"
		[ $i = "php-fpm" ] && j="php-cgi"
		[ $i = "php-daemon" ] && j="daemon.php"
                ps -ef|grep $j|grep -vq grep 
        	if [ $? = 0 ] ;then
                	printf "$YELLOW_COL %-10s $NORMAL_COL\t is running $GREEN_COL[ OK ]$NORMAL_COL\n" $i
		else
                	printf "$YELLOW_COL %-10s $NORMAL_COL\t is stopped $RED_COL[ Fail ]$NORMAL_COL\n" $i
		fi
        fi
done

JDBC_PORT=`sed -r -n '/jdbc.url/s#.*jdbc:(.*)/talk?.*#\1#gp' /opt/javaserver/config.properties`
printf "$YELLOW_COL Java jdbc connect : $GREEN_COL %s $NORMAL_COL\n" $JDBC_PORT

echo
ls -alF --color /var/lib/GeoIP/GeoIPCity.dat
echo

if [ ! -z $1 ] ;then
	if [ $1 = "stop" ];then
		opt="stop"
	else
		opt="start"
	fi
	for i in $SERVICES;do
		[ $i = "sshd" ] && [ $opt = "stop" ] && continue
		echo $i|grep -q "^#"
		if [ $? != 0 ] ;then
			service $i $opt
		fi
	done
fi
