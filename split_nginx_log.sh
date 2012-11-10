#!/bin/bash
# added by geminis 2010/11/05
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg
# The Nginx logs path
[ -z $NGINX_LOG ] && NGINX_LOG="/var/log/53kf/nginx/"

if [ `date +%k`	= 0 ];then
	year=`date -d "yesterday" +"%Y"`
	month=`date -d "yesterday" +"%m"`
	day=`date -d "yesterday" +"%d"`
	time=$year$month$day"24"

	mkdir -p ${NGINX_LOG}/$year/$month/$day
	mv ${NGINX_LOG}/access.log ${NGINX_LOG}/access.log.$time
	mv ${NGINX_LOG}/sendmsg.log ${NGINX_LOG}/sendmsg.log.$time
	kill -USR1 `cat /var/run/nginx.pid`
	grep "kf.php" ${NGINX_LOG}/access.log.$time > ${NGINX_LOG}/kf.$time
	mv ${NGINX_LOG}/access.log.* ${NGINX_LOG}/$year/$month/$day/
	mv ${NGINX_LOG}/sendmsg.log.* ${NGINX_LOG}/$year/$month/$day/
else
	time=`date +%Y%m%d%H`
	mv ${NGINX_LOG}/access.log ${NGINX_LOG}/access.log.$time
	mv ${NGINX_LOG}/sendmsg.log ${NGINX_LOG}/sendmsg.log.$time
	kill -USR1 `cat /var/run/nginx.pid`
	grep "kf.php" ${NGINX_LOG}/access.log.$time > ${NGINX_LOG}/kf.$time
fi
