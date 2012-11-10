#!/bin/sh
# added by geminis 2010/11/05
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg

i=0;

while [ $i -lt 20 ];do
  ((i++));
  echo "---------------  $i  ------------------";
  result=$(mysql -u$MYSQL_USER -h192.168.0.253 -P3305 -p$MYSQL_PASS -e"show databases"|grep ^S[0-9])
  echo $result
  sleep 1;
done

