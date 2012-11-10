#!/bin/sh

# added by geminis 2010/11/05
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg
[ -z $LOG_EXPIRE_DAYS ] && LOG_EXPIRE_DAYS="1"

find /var/log/ -mtime +$LOG_EXPIRE_DAYS -a -type f | egrep "php-fpm|nginx" | xargs rm -rf []
find /var/log/ -name "sendmsg.*" -a -mmin +720 -a -type f -exec rm -rf {} \;
find /home/bak/ -mtime +$LOG_EXPIRE_DAYS -a -type f | xargs rm -rf []
find /tmp/ -name "processlist_*" -a -mtime +$LOG_EXPIRE_DAYS -a -type f | xargs rm -rf []
sleep 1
rm -rf /home/html/talk/compiled/*
rm -rf /var/spool/mail/root /var/spool/clientmqueue/*
> /var/log/btmp

# check zabbix_agentd and restart service
ps -e|grep -q zabbix_agentd
[ $? = 0 ] && /etc/init.d/zabbix_agentd restart
