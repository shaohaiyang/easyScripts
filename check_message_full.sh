#!/bin/sh
NUM="1000"

OLD_FILE="/tmp/.old_table_full"
NEW_FILE="/tmp/.new_table_full"

if [ -s $OLD_FILE ];then
	tail -n $NUM /var/log/messages | egrep "messages suppressed|table full" > $NEW_FILE
	diff -q $OLD_FILE $NEW_FILE
	if [ $? = 1 ];then
		sysctl -p
		sysctl -p
		sysctl -p
		mv -f $NEW_FILE $OLD_FILE
		echo "message table full at `date`" >> /var/log/53kf/message_table_full.log
	fi
else
	tail -n $NUM /var/log/messages | egrep "messages suppressed|table full" > $OLD_FILE
fi
