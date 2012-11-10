#!/bin/sh
if [ -z $1 ];then
	ps aux | awk 'BEGIN{rss = 0;print "rss(MiB)"} {rss+=$6} END{print rss/1024  }'
elif [ $1 = "53kf" ];then
	for i in comet nginx mysqld php-cgi daemon.php memcached zabbix_agent;do
		ps aux | grep $i | grep -v grep | awk 'BEGIN{rss = 0;print "Program \t\t\t RSS(MiB)"} {rss+=$6} END{print "-> '"$i"'\t\t\t" rss/1024 }'
	done
else
	ps aux | grep $1 | grep -v grep | awk 'BEGIN{rss = 0;print "rss(MiB)"} {rss+=$6} END{print rss/1024  }'
fi
