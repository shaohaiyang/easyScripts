#!/bin/sh
# this line is include the configuration file
.  /etc/check_server.conf
declare -a LOSS
declare -a DATE
declare -a time
SLEEP=2
DOMAIN="53kf.com"

sendwarn() {
        FILE=`/usr/local/bin/mktemp /var/spool/sms/outgoing/send_XXXXXX`

        echo "To: $1" >> $FILE
        echo "Alphabet: $3" >> $FILE
        echo "" >> $FILE
        if [ "$3" = "ISO" ];then
                echo "$2" >> $FILE
        else
                echo "$2" | iconv -f UTF-8 -t UCS-2BE >> $FILE
        fi
}

send_fetion() {
        curl http://mon.53kf.com/f.php?phone="13655896157"\&pwd="reallyred520"\&to="$1"\&msg="$2"
}

chk_domain_status(){
	curl -s "http://reports.internic.net/cgi/whois?whois_nic=$DOMAIN&type=domain"|grep -q -i "Status:.*ok"
	if [ $? = 1 ];then
		STR="$DOMAIN is locked by `date`."
		echo $STR >> /tmp/aaaaa
		mobile_num="13666626825,13655813908"
		send_fetion $mobile_num "$STR"
	fi
}

call(){
	LOSS[$2]=$(ping $1 -c10 -s1 -i 1|grep loss|awk -F, '{print $3}'|awk -F% '{print $1}')
        if [ ${LOSS[$2]} -gt 70 ] ;then
                DATE[$2]=`date +%H:%m-%Y/%m/%d`
                time[$2]=$(grep $1 $LOG|awk '{print $2}')
		if [ -z ${time[$2]} ];then
			time[$2]=1 && echo "$1     ${time[$2]}   $DATE   $PHOTO  ${LOSS[$2]}% $P" >> $LOG
		else
			((time[$2]++))
			sed -r -i "/$1/s@.*@$1        ${time[$2]}   $DATE   $PHOTO  ${LOSS[$2]}% $P@g" $LOG
		fi

                if [ ${time[$2]} -le $LIMIT ];then
                        eval PERSONS=\$$P
                        for Person in $PERSONS;do
                                echo $Person|grep -q "^[#]"
                                [ $? = 0 ] && continue

                                #name=`echo $Person|cut -f1 -d#`
                                mobile_num=`echo $Person|cut -f2 -d#`
                                STR="(${time[$2]})Warning! $1(Contact:$PHOTO) offline at ${DATE[$2]}.(${LOSS[$2]} lost)"
                                send_fetion $mobile_num "$STR"
                        done
                fi
        else
                [ -f $LOG ] && sed -r -i "/$1/d" $LOG
        fi
}

J=1
if [ "$1" = "test" ];then
         STR="Test sms! The sms warning is working."
         echo $STR
         #sendwarn $TEST_PHONE "$STR" ISO
         send_fetion $TEST_PHONE "$STR"
         exit 0
fi

if [ $CHK_ENABLE = "1" ];then
        for item in $CHK_LIST;do
        echo $item|grep -q "^[#]"
        [ $? = 0 ] && continue

        T=`echo $item|cut -d"|" -f1`
        P=`echo $item|cut -d"|" -f2`
        eval T=\$$T

            for i in $T;do
                echo $i|grep -q "^[#]"
                [ $? = 0 ] && continue

                IP=`echo $i|awk -F# '{print $1}'`
                PHOTO=`echo $i|awk -F# '{print $2}'`
                LIMIT=`echo $i|awk -F# '{print $3}'`

                [ -z $LIMIT ] && LIMIT="3" # 3 times

                ((J++))
                call $IP $J &
                sleep $SLEEP
	    done
	done
	chk_domain_status
fi
