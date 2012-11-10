#!/bin/bash                                                                                        
DEV=$1
LIMIT=$2
WARN=$3
TIME=$4
mobile_num="13666626825,13655813908"
LOCK="/tmp/.exchange_proxy.lock"

[ -z $DEV ] && echo "$0 ethx limit_band(kbps) warn_limit(kbps) seconds" && exit 0
[ -z $LIMIT ] && LIMIT=800000	# 800 kbps
[ -z $WARN ]  &&  WARN=900000 	# 900 kbps
[ -z $TIME ]  &&  TIME=10

send_fetion() {
        curl http://mon.53kf.com/f.php?phone="13655896157"\&pwd="reallyred520"\&to="$1"\&msg="$2"
}

while : ; do
	net_flood=`ifconfig $DEV|sed -n "8"p`
        rx_before=`echo $net_flood|awk '{print $2}'|cut -c7-`

        sleep $TIME

	net_flood=`ifconfig $DEV|sed -n "8"p`
        rx_after=`echo $net_flood|awk '{print $2}'|cut -c7-`

        rx_result=$[(rx_after-rx_before)/$TIME]

	over_bw=$[(rx_result-LIMIT)]
	if [ $over_bw -gt 0 ];then
                BOOL=`echo "$rx_result>$WARN"|bc` # too high bandwidth to exchange,anti ddos
		BAND=`echo "scale=0;$rx_result/1000"|bc`

                if [ $BOOL -eq 1 ];then
                        if [ ! -e $LOCK ];then
                                HOST=`hostname|cut -d- -f2|tr 'A-Z' 'a-z'`
                                /etc/init.d/nginx stop
                                sleep 3;sysctl -p;sleep 2;sysctl -p;sleep 1;sysctl -p
                                ssh -i /root/.ssh/53kf-server.ssh -o StrictHostKeyChecking=no -n mon.53kf.com "smart_exchange.sh $HOST"
                                touch $LOCK
                                /etc/init.d/nginx start
                                STR="Band Disaster: `hostname` $BAND Kbps at `date`,swith to proxy."
                        else
                                STR="Band Disaster: `hostname` $BAND Kbps at `date`,keep at proxy."
                                sysctl -p
                        fi
                else
                        STR="Band Warn: `hostname` $BAND Kbps at `date`"
                        sysctl -p
                fi
                echo $STR >> /tmp/band_warning.log
                send_fetion $mobile_num "$STR"
	fi
        sleep $TIME
done
