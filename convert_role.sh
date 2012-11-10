#!/bin/sh
# added by geminis 2010/11/05
KF_CONFIG="/etc/53kf.cfg"
KF_CRON="/etc/cron.d/53kf"

[ -s $KF_CONFIG ] && source $KF_CONFIG

DEV=`ip link|grep UP|awk -F: '/eth/{print $2}'|tail -1`
TMP="/tmp/slave.tmp"

mysql_init(){
mysqladmin -u$MYSQL_USER password $MYSQL_PASS
mysqladmin -u$MYSQL_USER -h127.0.0.1 password $MYSQL_PASS
}

convert_master(){

mkdir -p /var/share/{download,upload}
chown -R nobody.nobody /var/share/
echo "/var/share/upload     192.168.0.0/24(rw,no_root_squash,async,no_subtree_check)" > /etc/exports
echo "/var/share/download   192.168.0.0/24(rw,no_root_squash,async,no_subtree_check)" >> /etc/exports
echo "RPCNFSDCOUNT=32" >> /etc/sysconfig/nfs

sed -r -i "/tcp_keepalive_time/s:=.*:= 60:g" /etc/sysctl.conf
sed -r -i "/ip_conntrack_tcp_timeout_established/s:=.*:= 30:g" /etc/sysctl.conf
sed -r -i "/ip_forward/s:=.*:= 1:g" /etc/sysctl.conf

sed -r -i "/master-slave/d" /etc/rc.local
sed -r -i "/connect_sw/d" /etc/rc.local
echo "connect_sw.sh allow" >> /etc/rc.local
sed -r -i "/split_/d"  $KF_CRON
sed -r -i "/master-slave/d"  $KF_CRON
sed -r -i "/check_gearmand/d"  $KF_CRON
echo "* * * * * root (/usr/bin/check_gearmand.sh)" >>  $KF_CRON
sed -r -i "/# mysql proxy/d" $MYSQL_CONF
sed -r -i "/^port=/s:.*:port=$MASTER_PORT:g" $MYSQL_CONF
sed -r -i "/6ddatabase.com$/s:.*:127.0.0.1\t\t6ddatabase.com:g" /etc/hosts

ln -snf /opt/nginx/conf/nginx.conf.lb /opt/nginx/conf/nginx.conf

#grant replication slave on *.* to 'repuser'@'%' identified by 'xxxxx';
#flush privileges;
#server-id = 1
#log-bin=mysql-bin
#binlog-ignore-db=mysql
#binlog-ignore-db=test

mysql_init
}

convert_init(){
sed -r -i "/master-slave/d" /etc/rc.local
sed -r -i "/master-slave/d"  $KF_CRON
sed -r -i "/check_gearmand/d"  $KF_CRON
echo "* * * * * root (/usr/bin/check_gearmand.sh)" >> $KF_CRON

sed -r -i "/masterdb$/s:.*:127.0.0.1\tmasterdb:g" /etc/hosts
sed -r -i "/6ddatabase.com$/s:.*:127.0.0.1\t6ddatabase.com:g" /etc/hosts
sed -r -i "/6ddatabase.com2$/s:.*:127.0.0.1\t6ddatabase.com2:g" /etc/hosts
sed -r -i "/kf.memserver$/s:.*:127.0.0.1\tkf.memserver:g" /etc/hosts
sed -r -i "/talkSessionServer$/s:.*:127.0.0.1\ttalkSessionServer:g" /etc/hosts

ln -snf /opt/nginx/conf/nginx.conf.proxy /opt/nginx/conf/nginx.conf

sed -r -i "/# mysql proxy/d" $MYSQL_CONF
sed -r -i "/^port=/s:.*:port=$MASTER_PORT:g" $MYSQL_CONF

mysql_init
}

convert_slave(){
SID=`awk -F= '/IPADDR/{print $2}' /etc/sysconfig/network-scripts/ifcfg-$DEV|cut -d. -f4`

STRING="
server-id=$SID\t\t\t# mysql proxy\n
master-host=$MASTER_HOST\t# mysql proxy\n
master-user=$SLAVE_USER\t\t# mysql proxy\n
master-password=$SLAVE_PASS\t\t# mysql proxy\n
master-port=$MASTER_PORT\t\t# mysql proxy\n
master-connect-retry=10\t# mysql proxy\n
slave-net-timeout=3600\t# mysql proxy\n
slave-skip-errors=all\t# mysql proxy\n"

if [ ! -z "$IGNORE_DB" ];then
	for i in $IGNORE_DB;do
		STRING=$STRING"replicate-ignore-db=$i\t# mysql proxy\n"
	done
fi

if [ ! -z "$REPT_DB" ];then
	for i in $REPT_DB;do
		STRING=$STRING"replicate-do-db=$i\t\t# mysql proxy\n"
	done
fi

echo -en $STRING > $TMP
sed -r -i "/mysqlcheck/d" /etc/services
echo -en "mysqlchk_read\t63306/tcp\t\t# mysqlcheck" >> /etc/services

sed -r -i '/mount_nfs/d' /etc/rc.local
sed -r -i '/iproute/a\/usr/bin/mount_nfs.sh' /etc/rc.local
echo "" >> /etc/rc.local

sed -r -i "/master-slave/d" /etc/rc.local
echo "/usr/bin/rsync_mysql_master.sh sync   # master-slave sync action" >> /etc/rc.local
sed -r -i "/create_upload_dir/d" /etc/rc.local
echo "/usr/bin/create_upload_dir.sh" >> /etc/rc.local

sed -r -i "/get_/d"  $KF_CRON
sed -r -i "/check_/d"  $KF_CRON
sed -r -i "/cron_down/d"  $KF_CRON
sed -r -i "/DBBackup/d" / $KF_CRON
sed -r -i "/master-slave/d"  $KF_CRON

sed -r -i "/masterdb$/s:.*:$MASTER_HOST\tmasterdb:g" /etc/hosts
sed -r -i "/6ddatabase.com$/s:.*:$MASTER_HOST\t6ddatabase.com:g" /etc/hosts
sed -r -i "/6ddatabase.com.ro$/s:.*:$MASTER_HOST\t6ddatabase.com.ro:g" /etc/hosts
sed -r -i "/kf.memserver$/s:.*:$MASTER_HOST\tkf.memserver:g" /etc/hosts
sed -r -i "/talkSessionServer$/s:.*:$MASTER_HOST\ttalkSessionServer:g" /etc/hosts

ln -snf /opt/nginx/conf/nginx.conf.backend /opt/nginx/conf/nginx.conf

sed -r -i "/# mysql proxy/d" $MYSQL_CONF
sed -r -i "/\[mysqld\]/r $TMP" $MYSQL_CONF
sed -r -i "/^bind-address/s:.*:bind-address=0.0.0.0:g" $MYSQL_CONF
sed -r -i "/^port=/s:.*:port=$SLAVE_PORT:g" $MYSQL_CONF

mysql_init
rm -rf $TMP
}

case "$1" in
        init)
                convert_init
                chkconfig nginx on
                chkconfig php-fpm on
                chkconfig mysqld on
		chkconfig javacomet on
		chkconfig php-daemon on
		chkconfig memcached on
		chkconfig gearmand on
                chkconfig zabbix_agentd on
		chkconfig xinetd on
                chkconfig varnish off
                chkconfig haproxy off
		chkconfig ntpd off
		chkconfig nfs off
		chkconfig nfslock off
		chkconfig portmap off
		chkconfig keepalived off
                ;;
        slave)
                convert_slave
                chkconfig nginx on
                chkconfig php-fpm on
                chkconfig mysqld on
		chkconfig xinetd on
		chkconfig nfslock on
		chkconfig portmap on
		chkconfig nfs off
		chkconfig ntpd off
		chkconfig keepalived off
		chkconfig javacomet off
		chkconfig php-daemon off
		chkconfig memcached off
		chkconfig gearmand off
                chkconfig zabbix_agentd off
                chkconfig varnish off
                chkconfig haproxy off
                ;;
        master)
		convert_master
		chkconfig ntpd on
		chkconfig nfs on
		chkconfig nfslock on
		chkconfig portmap on
                chkconfig nginx on
                chkconfig haproxy on
		chkconfig keepalived off
                chkconfig mysqld on
                chkconfig javacomet on
                chkconfig php-daemon on
                chkconfig memcached on
                chkconfig gearmand on
                chkconfig xinetd off
                chkconfig php-fpm off
                chkconfig varnish off
		;;
	*)
		echo "Usage: $0 { init | master | slave }"
		;;
esac
exit 0
