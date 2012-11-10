#!/bin/sh
# added by geminis 2010/11/05
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg

SLAVE_SQL="mysql -P$SLAVE_PORT -u$MYSQL_USER -p$MYSQL_PASS"
SLAVE_SQL_CHK="mysql -P$SLAVE_PORT -u$MYSQL_USER -p$MYSQL_PASS -e \"SHOW SLAVE STATUS \G\"|egrep \"Read_Master_Log_Pos|Exec_Master_Log_Pos\""
MASTER_SQL_CHK="mysql -u$MYSQL_USER -p$MYSQL_PASS -e \"SHOW MASTER STATUS \G\"|grep Position"
MASTERDUMP_SQL="mysqldump -u$MYSQL_USER -p$MYSQL_PASS --master-data --character-set=utf8 --opt"
SSH="ssh"

check(){
	for host in $PROXY_HOST;do
		echo "$host" |grep -q ^#
		[ $? = 0 ] && continue

		i=`echo $host|awk -F@ '{print $2}'`
                echo -en "$i\n\t"
                $SSH $i "date"
                $SSH $i "$SLAVE_SQL_CHK"
	done

	echo "Master Log Position"
	eval $MASTER_SQL_CHK
}

dumpdata(){
	$MASTERDUMP_SQL $DATABASE > /home/mysql/$DATABASE.sql
        for host in $PROXY_HOST;do
                echo "$host" |grep -q ^#
                [ $? = 0 ] && continue

                i=`echo $host|awk -F@ '{print $2}'`
                echo $i

		rsync -avz -e "$SSH" /home/mysql/$DATABASE.sql $i:/home/mysql/
                $SSH $i "/etc/init.d/mysqld stop"
                $SSH $i "rm -rf /home/mysql/{$DATABASE,master.info,relay-log.info,mysqld-*,mysql-bin.*}"
                $SSH $i "/etc/init.d/mysqld start"
		$SSH $i "$SLAVE_SQL -e \"STOP SLAVE;\""
        	$SSH $i "mysqladmin -u$MYSQL_USER -p$MYSQL_PASS create $DATABASE"
		$SSH $i "$SLAVE_SQL $DATABASE < /home/mysql/$DATABASE.sql"
		$SSH $i "$SLAVE_SQL -e \"START SLAVE;\""
        done
}

case "$1" in
	check|chk)
		check;;
	dump)
		dumpdata;;
	*)
		echo "Usage: $0 (check|dump)";;
esac
