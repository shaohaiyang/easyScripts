#!/bin/sh
# added by geminis 2010/11/05
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg
[ -z $MYSQL_LOG ] && MYSQL_LOG="/var/log/53kf/mysql"
TMP="/tmp/slave.tmp"
DEV=`/sbin/ip add |grep "192\.168\.0\."|sed -r 's:.*eth(.*):eth\1:g'`

SLAVE_SQL="mysql -P$SLAVE_PORT -u$MYSQL_USER -p$MYSQL_PASS"
MASTER_SQL="mysql -u$MYSQL_USER -p$MYSQL_PASS --character-set=gbk"
MASTERDUMP_SQL="mysqldump -u$MYSQL_USER -p$MYSQL_PASS --master-data --character-set=gbk --opt"
SSH="ssh -i /root/.ssh/53kf-server.ssh"

sync_new_master(){
	$SLAVE_SQL -e "STOP SLAVE;"
	$SLAVE_SQL -e "CHANGE MASTER TO MASTER_HOST=\"$MASTER_HOST\";"
	$SLAVE_SQL -e "START SLAVE;"
}

convert_master(){
	$SLAVE_SQL -e "STOP SLAVE;"
	$SLAVE_SQL -e "RESET MASTER;"
	rm -rf /home/mysql/{master.info,relay-log.info}
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
	sed -r -i "/# mysql proxy/d" $MYSQL_CONF
	sed -r -i "/server-id/d" $MYSQL_CONF

	netstat -ntpl|grep -q ":3305"
	if [ $? != 0 ];then
		sed -r -i "/log-bin/d" $MYSQL_CONF
		sed -r -i "/binlog-ignore-db/d" $MYSQL_CONF
	fi
	sed -r -i "/\[mysqld\]/r $TMP" $MYSQL_CONF
	sed -r -i "/^bind-address/s:.*:bind-address=0.0.0.0:g" $MYSQL_CONF
	sed -r -i "/^port=/s:.*:port=$SLAVE_PORT:g" $MYSQL_CONF
	rm -rf $TMP
}

clean() {
	/etc/init.d/mysqld stop
	rm -rf /home/mysql/{master.info,relay-log.info,mysqld-*,mysql-bin.*}
	rm -rf /home/mysql/$DATABASE
}

keep_sync() {
	grep -q master-port /etc/my.cnf
	[ $? =  0 ] || convert_slave

	SLAVE_PORT=`grep ^port /etc/my.cnf |cut -d= -f2`
	MASTER_PORT=`grep master-port /etc/my.cnf |cut -d= -f2|awk '{print $1}'`
	MASTER_HOST=`grep master-host /etc/my.cnf |cut -d= -f2|awk '{print $1}'`

	$SLAVE_SQL -e "show slave status \G"|egrep "Slave_IO_Running|Slave_SQL_Running"|grep -q "No"
	if [ $? = 0 ];then
		SYNC=$($SLAVE_SQL -e "show slave status \G"|egrep -w "Master_Log_File|Exec_Master_Log_Pos"|sed -e '/Master_Log_File/s@: @="@g' -e '/Exec_Master_Log_Pos/s@: @=@g' -e 's#$#"#g' -e 's# ##g' -e 's#Exec_##g'|tr '\n' ',')
		SYNC="CHANGE MASTER TO MASTER_PORT=$MASTER_PORT,MASTER_HOST=\"$MASTER_HOST\",${SYNC%\",};"
		echo $SYNC
		echo "Slave is broken. rsync again at `date`" >> $MYSQL_LOG/mysql-slave.log
		$SLAVE_SQL -e "slave stop"
		$SLAVE_SQL -e "$SYNC"
		$SLAVE_SQL -e "slave start"
	else
		echo "Running fine."
	fi
}

case "$1" in
		init_backup)
			convert_slave
			# change mysql port to 3306
			sed -r -i '/3307/s:3307:3306:g' /etc/my.cnf
                        sed -r -i '/^port=/s:.*:port=3306:g' /etc/my.cnf

			$SSH $KEEPALIVED_MASTER "$MASTERDUMP_SQL $DATABASE > /home/mysql/$DATABASE.sql"
			/etc/init.d/mysqld stop
			rsync -avz -e "$SSH" $KEEPALIVED_MASTER:/home/mysql/$DATABASE.sql /home/mysql/
			/etc/init.d/mysqld start
			
			$SLAVE_SQL -e "STOP SLAVE;"
                        $SLAVE_SQL -e "flush tables;"
			mysqladmin  -u$MYSQL_USER -p$MYSQL_PASS create $DATABASE
			$MASTER_SQL $DATABASE < /home/mysql/$DATABASE.sql
			$SLAVE_SQL -e "START SLAVE;"
			;;
		init_slave)
                        convert_slave

                        $SSH $MASTER_HOST "$MASTERDUMP_SQL $DATABASE > /home/mysql/$DATABASE.sql"
                        /etc/init.d/mysqld stop
                        #rsync -avz -e "$SSH" --exclude "$DATABASE" --exclude "mysql-bin.*" $MASTER_HOST:/home/mysql/ /home/mysql/
			rsync -avz -e "$SSH" $KEEPALIVED_MASTER:/home/mysql/$DATABASE.sql /home/mysql/
                        /etc/init.d/mysqld start

                        $SLAVE_SQL -e "STOP SLAVE;"
                        $SLAVE_SQL -e "flush tables;"
                        mysqladmin  -u$MYSQL_USER -p$MYSQL_PASS create $DATABASE
                        $MASTER_SQL $DATABASE < /home/mysql/$DATABASE.sql
                        $SLAVE_SQL -e "START SLAVE;"
			;;
		convert_master)
			convert_master
			;;
		convert_slave)
			convert_slave
			;;
		sync_new_master)
			sync_new_master
			;;
		clean)
			clean
			;;
		sync)
			keep_sync
			;;
		*)
			echo "$0 {init_backup | init_slave | convert_master | convert_slave | sync_new_master | clean | sync}"
			;;
esac
