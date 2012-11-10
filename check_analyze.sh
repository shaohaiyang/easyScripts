#!/bin/sh
# added by geminis 2011/06/01
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg
[ -z $MYSQL_LOG ] && MYSQL_LOG="/var/log/53kf/mysql"

LOG="$MYSQL_LOG/check_table.log"
TMP="/tmp/list"

MYSQL="mysql -u$MYSQL_USER -p$MYSQL_PASS $DATABASE"

# check mysqld memory limitation
MYSQL_AVG="2000"
MYSQL_MEM=`get_rss.sh mysqld|grep [0-9]|cut -d. -f1`

if [ "$MYSQL_MEM" -gt $MYSQL_AVG ];then
        /etc/init.d/mysqld condrestart
	sleep 3
fi

ls /home/mysql/$DATABASE/*.frm | sed -r 's:.*/(.*).frm:\1:g' > $TMP

sed -r -i '/_bak/d'  $TMP
sed -r -i '/_old/d'  $TMP
egrep "^message|^talk|^worker|^company|^statistic$" $TMP > /tmp/.a
egrep -v "^message|^talk|^worker|^company|^statistic$" $TMP > /tmp/.b

mv /tmp/.a $TMP
cat /tmp/.b >> $TMP
rm -rf /tmp/.b

OPT=$1
if [ -z $OPT ] ;then
	OPT="show"
else
	DAY=`date +%w`
	if [ $DAY = 0 ];then
		OPT="check"
	else
		OPT="analyze"
	fi
fi

if [ ! -z "$2" ] ;then
	OPT=$1
fi

echo "=== $OPT option `date`" >> $LOG
while read i;do
        case "$OPT" in
                show)
                        echo "show indexes table $i"
                        $MYSQL -e "show indexes from \`$i\`"
                        ;;
                analyze)
                        echo "analyze table $i"
                        $MYSQL -e "analyze table \`$i\`"
                        ;;
                check)
                        echo "check table $i"
                        $MYSQL -e "check table \`$i\`\G" |grep -q "Msg_text: OK"
			if [ $? != 0 ];then
				echo ">>> Repair table $i `date`" >> $LOG
				$MYSQL -e "repair table \`$i\`"
				sleep 1
				$MYSQL -e "check table \`$i\`"
			fi
                        ;;
                *)
                        echo "not supported"
        esac
	sleep 1
done < $TMP

echo "Finish $OPT option `date`" >> $LOG
rm -rf $TMP
