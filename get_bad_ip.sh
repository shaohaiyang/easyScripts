#!/bin/sh
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg

IPTABLE="/sbin/iptables"
OLD_FILE="/tmp/.old_bad_ip"
NEW_FILE="/tmp/.new_bad_ip"
FILE="/etc/bad_ip"

cd $NGINX_LOG

if [ -e $OLD_FILE ];then
	awk '/GET \/webCompany\.php HTTP/ {print $1}' access.log|sort|uniq > $NEW_FILE
        diff -q $OLD_FILE $NEW_FILE
        if [ $? = 1 ];then
                while read IP;do
                        $IPTABLE -t nat -I PREROUTING -s $IP -j DROP
                done < $NEW_FILE

                cat $NEW_FILE >> $FILE
                sort $FILE|uniq > /tmp/.bad_ip_tmp
                mv -f /tmp/.bad_ip_tmp $FILE
                mv -f $NEW_FILE $OLD_FILE
                echo "Web was attacked at `date`" >> /var/log/53kf/web_attacked.log
		sed -r -i '/GET \/webCompany\.php HTTP/d' access.log
        fi
else
	awk '/GET \/webCompany\.php HTTP/ {print $1}' access.log|sort|uniq > $OLD_FILE
	if [ -s $OLD_FILE ];then
		while read IP;do
			$IPTABLE -t nat -I PREROUTING -s $IP -j DROP
		done < $OLD_FILE

        	cat $OLD_FILE >> $FILE
        	sort $FILE|uniq > /tmp/.bad_ip_tmp
        	mv -f /tmp/.bad_ip_tmp $FILE
		sed -r -i '/GET \/webCompany\.php HTTP/d' access.log
	fi
fi


