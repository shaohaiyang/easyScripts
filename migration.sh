#!/bin/sh
DIR=`pwd`
SERVICES="gearmand memcached php-daemon php-fpm nginx"

yum install -y xinetd libmcrypt ntp screen e4fsprogs libtool-ltdl GeoIP

for i in $SERVICES;do
	/etc/init.d/$i stop
done

rm -rf /opt/{nginx,php,scws,memcached,gearmand,varnish}

cp -a $DIR/usr /
cp -a $DIR/etc/cron.d/53kf /etc/cron.d/
cp -a $DIR/etc/rc.d/init.d/* /etc/rc.d/init.d/
cp -a $DIR/opt/{nginx,php,scws,memcached,gearmand,varnish} /opt

ldconfig

for i in $SERVICES;do
	/etc/init.d/$i start
done

