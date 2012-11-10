#!/bin/bash
#
# This script checks 53kf all necessary services
# added by geminis 2010/11/05
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg

for host in $VARNISH_PROXY;do
        echo "$host" |grep -q ^#
        [ $? = 0 ] && continue

        i=`echo $host|awk -F@ '{print $2}'`

	echo ">>> $i Status ---------------------"
        ssh $i "mysql -u$MYSQL_USER -p$MYSQL_PASS mysql -e \"show slave status \G\""|egrep "Slave_IO_Running|Slave_SQL_Running|Seconds_Behind_Master"
        ssh $i 'df -h'|egrep "download|upload"
done


