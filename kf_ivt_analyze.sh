#!/bin/sh
DIR="/home/html/it"
DAYTIME=`date +%H`
SSH="ssh -i /root/.ssh/53kf-server.ssh -n"
mobile_num="13666626825,13655813908"

if [ `date +%k` = 0 ];then
        year=`date -d "yesterday" +"%Y"`
        month=`date -d "yesterday" +"%m"`
        day=`date -d "yesterday" +"%d"`
        DATE=$year$month$day
else
        DATE=`date +%Y%m%d`
fi

send_fetion() {
        curl http://mon.53kf.com/f.php?phone="13655896157"\&pwd="reallyred520"\&to="$1"\&msg="$2"
}

cd $DIR
find . -name kf.$DATE* > /tmp/srv_list
rm -rf /tmp/*_ip2
STR=""

while read FILE;do
        BASE=`basename $FILE`
        OLD_DATE=$(echo $BASE|cut -d\. -f2|cut -c 0-8)
        TIME=`echo $FILE|cut -d\. -f3`
        SERVER=`echo $FILE|cut -d/ -f2`
        RESULT="$DIR/$SERVER/RESULT/$OLD_DATE"
        RESULT_FILE="$RESULT/result-$TIME"
 
        mkdir -p $RESULT
 
        if [ ! -s $RESULT_FILE ];then
                awk '{print $7"#"$12}' $FILE | sed '/^#$/d' | \
                sed -r 's@.*kf.php\?arg=([0-9a-zA-Z-]*)&.*#(.*)$@\1 \2@' | \
                grep -v kf | awk '{a[$1]+=$2;b[$1]++} \
                END{for(i in a) print i,a[i],b[i]}' > $RESULT_FILE
        fi

	# add check more pv function
	if [ $DAYTIME -le 23 -a $DAYTIME -ge 7 ];then
	IP=`grep -w $SERVER /root/.ssh/ip|awk '{print $1}'`
	#SUM=/tmp/aaa
	#rm -rf $SUM
	#cat $RESULT/* > $SUM
	LOG=/tmp/$SERVER"_"$IP"_ip2"
	if [ ! -e $LOG ];then
		SUM=$RESULT/$(ls -tr $RESULT | grep result| tail -1)
		echo $SUM
		if [ $IP = "122.227.58.178" ];then # free3 free server
			band_num="50000000"
			minute="180"
		elif [ $IP = "60.191.223.40" ];then # free13 free server
			band_num="50000000"
			minute="180"
		elif [ $IP = "122.227.43.254" ];then # www41 try server
			band_num="100000000"
			minute="120"
		elif [ $IP = "60.191.223.34" ];then # vip2 try server
			band_num="200000000"
			minute="30"
		elif [ $IP = "60.191.223.32" ];then # vip4 try server
			band_num="200000000"
			minute="30"
		elif [ $IP = "60.191.223.37" ];then # vip8 try server
			band_num="200000000"
			minute="30"
		elif [ $IP = "122.227.58.121" ];then # vip10 try server
			band_num="200000000"
			minute="30"
		else
			band_num="150000000"
			minute="60"
		fi

                awk '{a[$1]+=$2;b[$1]+=$3} END{for(i in a) {if(a[i]>'"$band_num"') print i,a[i],b[i]}}' $SUM | sort -k2nr | head -n10 > $LOG
		#awk '{a[$1]+=$2;b[$1]+=$3} END{for(i in b) {if(b[i]>'"$PV_NUM"') print i,a[i],b[i]}}' $SUM | sort -k3nr | head -n10 > $LOG
		if [ -s $LOG ];then
			ITEM=`cat $LOG|tr '\n' '@'`
			STR=$STR$ITEM
			while read i;do
				bad=`echo $i|awk '{print $1}'`
				bw=`echo $i|awk '{print $2}'`
				grep -q $bad /opt/omp/whitelist
				if [ $? = 0 ];then
	                                limit=$(awk '/'"$bad"'/{print $2}' /opt/omp/whitelist)
					[ -z $limit ]  && continue
					[ $limit -ge $band_num ] && continue

					MINUTE=$(awk '/'"$bad"'/{print $3}' /opt/omp/whitelist)
					[ -z $MINUTE ] || minute=$MINUTE
				fi
				time=$(echo "scale=0; 60*$minute"|bc)

				if [ $bw -gt 400000000 ];then
					time="86400"
					echo "$i was attached `date`" >> /tmp/big_pv.log
					$SSH $IP "/usr/bin/block_referer_nginx.sh $bad $time \"Bandwidth was over.\""
					$SSH $IP "/usr/bin/block_guest_nginx.sh $bad $time \"Bandwidth was over.\""
				else
					echo "$i bandwidth was over `date`" >> /tmp/big_pv.log
					#$SSH $IP "/usr/bin/block_referer_nginx.sh $bad $time \"Bandwidth was over.\""
				fi
			done < $LOG
		fi
	fi
	fi
done < /tmp/srv_list

[ -z "$STR" ] || send_fetion $mobile_num "$STR bandwidth was over."
