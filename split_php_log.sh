#!/bin/bash
# This script run at 00:00

# added by geminis 2010/11/05
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg
# The php-fpm logs path
[ -z $PHP_DAEMON_LOG ] && PHP_DAEMON_LOG="/var/log/53kf/php/"

year=`date -d "yesterday" +"%Y"`
month=`date -d "yesterday" +"%m"`
day=`date -d "yesterday" +"%d"`

mkdir -p ${PHP_DAEMON_LOG}/$year/$month/
mv ${PHP_DAEMON_LOG}/php-fpm.log ${PHP_DAEMON_LOG}/$year/$month/php-fpm-$year-$month-$day.log
kill -USR1 `cat /var/run/php-fpm.pid`
