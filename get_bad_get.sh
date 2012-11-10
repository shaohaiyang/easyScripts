#!/bin/sh
# added by geminis 2010/11/05
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg

NUM_LOG="1000"
GET_WARN="150"
HEAD_NUM="3"
LONG_TIME="10800"

[ -z $1 ] || NUM_LOG=$1
[ -z $2 ] || GET_WARN=$2
[ -z $3 ] || HEAD_NUM=$3
[ -z $4 ] || LONG_TIME=$4

LOG="$NGINX_LOG/access.log"
TMP_BAD="/tmp/bad_get.log"
TMP_BAD2="/tmp/bad_guy"
mobile_num="13666626825,13655813908"

send_fetion() {
        curl http://mon.53kf.com/f.php?phone="13655896157"\&pwd="reallyred520"\&to="$1"\&msg="$2"
}

rm -rf $TMP_BAD2

tail -$NUM_LOG $LOG|grep "arg="|grep "GET.*webCompany.php"  > $TMP_BAD
awk -F~ '{print $3}' $TMP_BAD|grep "webCompany.php"|sort|uniq -c|sort -k1nr|head -$HEAD_NUM|sed 's/^[ ]*//g'|awk -F'"' '{if($1>'"$GET_WARN"') print $2"#"$1}' > $TMP_BAD2

if [ -s $TMP_BAD2 ];then
	while read LINE;do
		URL=`echo "$LINE"|cut -d# -f1`
		TIME=`echo "$LINE"|cut -d# -f2`
		STR=`echo $URL | awk -F'?' '{print $2}' | awk '{print $1}'`
		/usr/bin/block_guest_nginx.sh "$STR" $LONG_TIME "-> DDoS attack: $TIME"
	done < $TMP_BAD2
	/etc/init.d/nginx reload
	/usr/bin/send_ddos.py
	send_fetion $mobile_num "DDoS: `hostname` $STR `date`"
fi
