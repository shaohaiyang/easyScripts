#!/bin/sh
# added by geminis 2011/06/01
################################################################################
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg
[ -z $MYSQL_LOG ] && MYSQL_LOG="/var/log/53kf/mysql"

LOG="$MYSQL_LOG/check_table.log"
TMP="/tmp/list"

MYSQL="mysql -u$MYSQL_USER -p$MYSQL_PASS $DATABASE"

ls /home/mysql/$DATABASE/*.frm | sed -r 's:.*/(.*).frm:\1:g' > $TMP
sed -r -i '/_bak/d'  $TMP
sed -r -i '/_old/d'  $TMP
egrep "^message|^talk|^worker|^company|^statistic$" $TMP > /tmp/.a
egrep -v "^message|^talk|^worker|^company|^statistic$" $TMP > /tmp/.b

mv /tmp/.a $TMP
cat /tmp/.b >> $TMP
rm -rf /tmp/.b
################################################################################
/etc/init.d/nginx stop
cp /home/html/talk/www/stat.php /tmp/stat.php -a
echo '' >/home/html/talk/www/stat.php

TABLES=`egrep -v "stat_|statistic_" $TMP`
for i in $TABLES;do
	$MYSQL -e "repair table \`$i\`"
	$MYSQL -e "analyze table \`$i\`"
done

/etc/init.d/nginx restart
/etc/init.d/javacomet restart
sleep 30

TABLES=`egrep -v "stat_|statistic_" $TMP`
for i in $TABLES;do
	$MYSQL -e "analyze table \`$i\`"
done

TABLES=`grep "stat_" $TMP`
for i in $TABLES;do
	$MYSQL -e "repair table \`$i\`"
	$MYSQL -e "analyze table \`$i\`"
done

TABLES=`grep "statistic_" $TMP`
for i in $TABLES;do
	$MYSQL -e "repair table \`$i\`"
	$MYSQL -e "analyze table \`$i\`"
done

cp /tmp/stat.php /home/html/talk/www/stat.php -a

sleep 10

while read i;do
	$MYSQL -e "analyze table \`$i\`"
done < $TMP

rm -rf $TMP
