#!/bin/sh
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg

LOG_NUM="1000"
BAD_IP_NUM="100"
BAD_REQ_NUM="150"
BAD_REF_NUM="150"
BAD_AGT_NUM="150"

FILE="/tmp/.old_bad_req"
#URL="GET \/kf\.php\?arg=mjt7050"
URL=""
[ -z  "$URL" ] && URL="GET"

cd $NGINX_LOG

tail -n $LOG_NUM access.log > $FILE

awk -F~ '/'"$URL"'/{print $1,"~",$3,"~",$6,"~",$7}' $FILE > $FILE.bak

#sort -k1 $FILE.bak|uniq -c |sort -k1nr > /tmp/bad_ip
#for i in $(awk '{if($1>'"$BAD_IP_NUM"') print $2}' /tmp/bad_ip);do
#	echo "$i"
#done

sort -k2 $FILE.bak|uniq -c |sort -k1nr > /tmp/bad_req
for i in "$(awk '{if($1>'"$BAD_REQ_NUM"') {split($0,a,"~");print a[2]}}' /tmp/bad_req)";do
	[ ! -z "$i" ] && block_guest_nginx.sh "$i"
done

#sort -k3 $FILE.bak|uniq -c |sort -k1nr > /tmp/bad_ref
#for i in "$(awk '{if($1>'"$BAD_REF_NUM"') {split($0,a,"~");print a[3]}}' /tmp/bad_ref)";do
#	echo "$i"
#done

sort -k4 $FILE.bak|uniq -c |sort -k1nr > /tmp/bad_agt
for i in "$(awk '{if($1>'"$BAD_AGT_NUM"') {split($0,a,"~");print a[4]}}' /tmp/bad_agt)";do
	[ ! -z "$i" ] && block_agent_nginx.sh "$i"
done
