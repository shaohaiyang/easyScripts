#!/bin/sh
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg

DIR="/opt/coreseek/"
CONF="/opt/coreseek/etc/csft.conf"

DATA="talk_his"
DATA_DELTA="talk_his_delta"

SEARCHD=$DIR"bin/searchd"
INDEXER=$DIR"bin/indexer"

start() {
	mkdir -p $DIR/var/{data,delta}
	mkdir -p /var/log/53kf/coreseek
	$SEARCHD -c $CONF
}

stop() {
	$SEARCHD -c $CONF --stop
}

check() {
	ps -ef|grep -w "searchd -c"|grep -vq grep
	if [ $? != 0 ];then
		echo "coreseek restart at `date`" >> /var/log/53kf/coreseek/restart.log
		$SEARCHD -c $CONF	
	fi
}

all() {
	mysql -u$MYSQL_USER -p$MYSQL_PASS $DATABASE -e "show tables"|grep -q counter
	if [ $? = 1 ];then
		mysql -u$MYSQL_USER -p$MYSQL_PASS $DATABASE -e "CREATE TABLE counter (uid int(11) NOT NULL auto_increment,talk_his_id int(11) default NULL,PRIMARY KEY(uid)) ENGINE=MyISAM  DEFAULT CHARSET=utf8"
	fi
	$INDEXER -c $CONF --all
}

delta() {
	$INDEXER -c $CONF $DATA_DELTA --rotate
	sleep 3
	renice 18 `pidof $INDEXER`
}

merge() {
	$INDEXER -c $CONF --merge $DATA $DATA_DELTA --rotate >> /var/log/53kf/coreseek/build.log
	sleep 3
	renice 18 `pidof $INDEXER`
}

case "$1" in
        start)
                start
                ;;
        stop)
                stop
                ;;
        restart)
                stop
                start
                ;;
        check)
                check
                ;;
        all)
		all
                ;;
        delta)
		delta
                ;;
	merge)
		merge
		;;
        *)
                echo $"Usage: $0 {start|stop|restart|check|all|delta|merge}"
                RETVAL=1
esac
exit $RETVAL

