#!/bin/sh
# added by geminis 2010/11/05
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg
[ -z $1 ] && opt="reload"
[ ! -z $1 ] && opt="restart"

MYSQL="mysql -u$MYSQL_USER -p$MYSQL_PASS "

LIST="/etc/53kf.cfg \
        /etc/sysctl.conf \
        /etc/firewall/ \
        /home/html/ \
        "
for host in $PROXY_HOST;do
        echo "$host" |grep -q ^#
        [ $? = 0 ] && continue
	
	i=`echo $host|awk -F@ '{print $2}'`

	ssh $i "sed -r -i '/aide/d' /etc/cron.d/53kf"
	ssh $i "sed -r -i '/get_53kf/d' /etc/cron.d/53kf"
	ssh $i "sed -r -i '/check_analyze/d' /etc/cron.d/53kf"
	ssh $i "sed -r -i '/DBBackup/d' /etc/cron.d/53kf"
	ssh $i "sed -r -i '/check_gearmand/d' /etc/cron.d/53kf"
	ssh $i "sed -r -i \"/ntpdate/s:(.*) -o3.*:\1 -o3 $TIME_SRV):g\" /etc/cron.d/53kf"

        for dir in $LIST;do
                rsync -avz --delete -k -e "ssh" $dir $i:$dir
        	ssh $i "/etc/init.d/nginx $opt"
	        ssh $i "/etc/init.d/php-fpm $opt"
        done
done

/etc/init.d/nginx $opt
find /home/.nginx-spool/ -type f |xargs rm -rf

