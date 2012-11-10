#!/bin/sh
mobile_num="13666626825,13655813908"
CMD="/opt/inotify/bin/inotifywait"
DEST_DIR="/home/html/talk/www/"
OPTS="close_write,delete,create,attrib"

send_fetion() {
        curl http://mon.53kf.com/f_bak.php?phone="13655896157"\&pwd="reallyred520"\&to="$1"\&msg="$2"
}

if [ $1 = "stop" ];then
        PID=$(ps -ef|grep $CMD|grep -v grep|awk '{print $2}')
        kill -9 $PID
        exit 0
fi

$CMD -mrq -e $OPTS $DEST_DIR --format "%w %e %f"|while read DIR EVENT FILE;do
        echo $FILE|grep -q ".php$"
        if [ $? = 0 ];then
                HOST=`hostname|cut -d- -f2|tr 'A-Z' 'a-z'`
                send_fetion $mobile_num "Spy $HOST: $DIR$FILE is created by badman"
        fi
done
