#!/bin/sh
# added by geminis 2010/11/05
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg

#[ -z "$*" ] && echo "Choose one table name as source! " && exit 0
DIR="/opt/coreseek/etc"
FILE1="$DIR/53kf_talk_his.template"
FILE2="$DIR/53kf_csft.template"
FILE3="$DIR/csft.conf"

mysql -u$MYSQL_USER -p$MYSQL_PASS $DATABASE -e "select talk_his,message from chat_tables"|grep talk_his|sort|uniq > /tmp/.table_list

while read i;do
	MESS=`echo $i|cut -d" " -f2`
	TALK=`echo $i|cut -d" " -f1`
	sed -r "s:talk_his:$TALK:g" $FILE1 > /tmp/$TALK.idx
	sed -r -i "s:message:$MESS:g" /tmp/$TALK.idx
	STR=$STR"/tmp/$TALK.idx "
done < /tmp/.table_list

cat $STR $FILE2 > $FILE3
sed -r -i 's:SELECT talk_his_d.*_id:SELECT talk_his_id:g' $FILE3
rm -rf $STR /tmp/.table_list
