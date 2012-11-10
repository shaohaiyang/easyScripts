#!/bin/sh
# added by geminis 2010/11/05
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg

SSH="ssh -i /root/.ssh/53kf-server.ssh"
SYNC="rsync -avz -e \"$SSH\""
HOST_LIST="www13 www9"
DOMAIN="53kf.com"
DIR_LIST="coreseek mmseg3"
CMD_LIST="/usr/bin/check_coreseek.sh /usr/bin/gen_sphinx_index.sh /usr/lib64/libodbc.* /usr/local/lib/libsphinxclient* /opt/php/lib/sphinx.so /opt/php/lib/amqp.so /opt/php/etc/php.ini /home/html/talk/www/test.php"
CREATE_TAB="CREATE TABLE counter (uid int(11) NOT NULL auto_increment,talkhis_id int(11) default NULL,PRIMARY KEY (uid)) ENGINE=MyISAM  DEFAULT CHARSET=utf8"

for host in $HOST_LIST;do
	HOST="$host.$DOMAIN"
	$SSH -n $HOST "mkdir -p /var/log/53kf/coreseek"
	$SSH -n $HOST "mysql -u$MYSQL_USER -p$MYSQL_PASS $DATABASE -e \"$CREATE_TAB\""

	for i in $DIR_LIST;do
		STR="$SYNC /opt/$i $HOST:/opt"
		eval $STR
	done

	for cmd in $CMD_LIST;do
		STR="$SYNC $cmd $HOST:$cmd"
		eval $STR
# crond task
	done
done


