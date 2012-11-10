#!/bin/sh
KEEP_LOG="/var/log/53kf/keepalived.log"
KEEP_CFG="/opt/keepalived/etc/keepalived.conf"

[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg
SSH="ssh -n"

# change 53kf config switch role
IP=$(/sbin/ip addr|grep 192.168.0.|sed -r 's:.*inet (.*)/.*:\1:g')
sed -r -i "/KEEPALIVED_/s:KEEPALIVED_.*:KEEPALIVED_MASTER=\"$IP\":g" /etc/53kf.cfg

# change mysql port to 3306
sed -r -i '/3307/s:3307:3306:g' /etc/my.cnf

# allow forward
sed -r -i "/connect_sw/d" /etc/cron.d/53kf
echo "*/5 * * * * root (/usr/bin/connect_sw.sh allow)" >> /etc/cron.d/53kf
/usr/bin/connect_sw.sh allow

# change keepalived setting to master role.
echo "+++ I am MASTER #`date`" >> $KEEP_LOG
sed -r -i "/BACKUP/s:BACKUP:MASTER:g" $KEEP_CFG
/etc/init.d/keepalived reload

# change mysql to new master
/usr/bin/rsync_mysql_master.sh convert_master

/etc/init.d/zabbix_agentd restart
/etc/init.d/gearmand restart
/etc/init.d/portmap restart
/etc/init.d/xinetd restart
/etc/init.d/memcached restart
/etc/init.d/haproxy config
/etc/init.d/haproxy restart
/etc/init.d/nfs restart
/etc/init.d/javacomet restart
/etc/init.d/php-daemon restart
/etc/init.d/nginx restart
sysctl -p

for host in $PROXY_HOST;do
	echo "$host" |grep -q ^#
	[ $? = 0 ] && continue

	i=`echo $host|awk -F@ '{print $2}'`
	$SSH $i "/usr/bin/rsync_mysql_master.sh sync_new_master"
	$SSH $i "umount -f /home/html/talk/www/upload"
	$SSH $i "umount -f /home/html/talk/www/download"
	$SSH $i "umount -f /home/html/talk/www/img/upload"
	$SSH $i "umount -f /home/html/talk/scws"
	$SSH $i "/usr/bin/mount_nfs.sh"
done

sed -r -i "/rsync_keepalived/d" /usr/bin/get_53kf_status.sh
sysctl -p
