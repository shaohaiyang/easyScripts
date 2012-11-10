#!/bin/sh
# added by geminis 2010/11/05
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg

LOG="$NGINX_LOG/access.log"

NUM_LOG="500000"
GET_WARN="50"
HEAD_NUM="20"

[ -z $1 ] || NUM_LOG=$1
[ -z $2 ] || GET_WARN=$2
[ -z $3 ] || HEAD_NUM=$3

TMP_BAD="/tmp/bad_get.log"
TMP_BAD2="/tmp/bad_guy"

rm -rf $TMP_BAD2

tail -$NUM_LOG $LOG|grep "arg="|grep "GET.*webCompany.php"  > $TMP_BAD
awk -F~ '{print $3}' $TMP_BAD|grep "webCompany.php"|sort|uniq -c|sort -k1nr|head -$HEAD_NUM|sed 's/^[ ]*//g'|awk -F'"' '{if($1>'"$GET_WARN"') print $2"#"$1}' > $TMP_BAD2

