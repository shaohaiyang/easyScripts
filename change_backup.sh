#!/bin/sh
KEEP_LOG="/var/log/53kf/keepalived.log"

grep -q "state MASTER" /opt/keepalived/etc/keepalived.conf
[ $? = 0 ] && echo "You are MASTER" && exit 0

echo "--- I am BACKUP #`date`" >> $KEEP_LOG

# change mysql port to 3306
sed -r -i '/3307/s:3307:3306:g' /etc/my.cnf

/usr/bin/rsync_mysql_master.sh sync_new_master

/etc/init.d/zabbix_agentd stop
/etc/init.d/nfs stop
/etc/init.d/javacomet stop
/etc/init.d/xinetd stop
/etc/init.d/php-daemon stop
/etc/init.d/portmap stop
/etc/init.d/memcached stop
/etc/init.d/gearmand stop
/etc/init.d/nginx stop

/usr/bin/connect_sw.sh deny
sed -r -i "/connect_sw/d" /etc/cron.d/53kf

sed -r -i "/rsync_keepalived/d" /usr/bin/get_53kf_status.sh
echo "/usr/bin/rsync_keepalived.sh" >> /usr/bin/get_53kf_status.sh
