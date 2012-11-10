#!/bin/sh
[ -z "$*" ] && echo "Choose one table name as source! " && exit 0

DIR="/opt/coreseek/etc"
FILE1="$DIR/53kf_talk_his.template"
FILE2="$DIR/53kf_csft.template"
FILE3="$DIR/csft.conf"

sed -r "s:talk_his:$1:g" $FILE1 > /tmp/$1.idx
sed -r -i "s:message:$2:g" /tmp/$1.idx

cat $FILE3 >> /tmp/$1.idx
sed -r -i 's:SELECT talk_his_d.*_id:SELECT talk_his_id:g' /tmp/$1.idx
mv /tmp/$1.idx $FILE3
