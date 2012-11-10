#!/bin/sh
DEV=$1
LIMIT=$2
WARN=$3
TIME=$4
mobile_num="13666626825,13655813908"

[ -z $DEV ] && echo "$0 ethx limit_band(KB) warn_limit(MB) minutes" && exit 0
[ -z $LIMIT ] && LIMIT="1250" # KB
[ -z $TIME ] && TIME=1
[ -z $WARN ] && WARN=35

WAIT=$(($TIME*60+3))
LIMIT=$(($LIMIT*8))	# convert to Kbit/s = 10Mbps

FILE="/tmp/$DEV.log"
LOCK="/tmp/.exchange_proxy.lock"
IP=`ifconfig $DEV|grep "inet addr"|sed -r -e "s#.*addr:(.*) Bcast.*#\1#g" -e "s: ::g"`

send_fetion() {
	curl http://mon.53kf.com/f.php?phone="13655896157"\&pwd="reallyred520"\&to="$1"\&msg="$2"
}

rm -rf /var/lock/iptraf/iptraf*
rm -rf $FILE
iptraf -d $DEV -t $TIME -B -L $FILE && renice -18 `pidof iptraf`

sleep $WAIT

BAND=$(awk '/Incoming/ {
		if(($2-'"$LIMIT"')>0) print $2;
	}' $FILE)

if [ ! -z "$BAND" ];then
        BAND=`echo "scale=0;$BAND/1000"|bc`
        BOOL=`echo "$BAND>$WARN"|bc` # too high bandwidth to exchange,anti ddos

	if [ $BOOL -eq 1 ];then
		if [ ! -e $LOCK ];then
			HOST=`hostname|cut -d- -f2|tr 'A-Z' 'a-z'`
			/etc/init.d/nginx stop
			sleep 3
			sysctl -p
			sleep 2
			sysctl -p
			sleep 1
			sysctl -p
			ssh -i /root/.ssh/53kf-server.ssh -o StrictHostKeyChecking=no -n mon.53kf.com "smart_exchange.sh $HOST"
			touch $LOCK
			/etc/init.d/nginx start
			STR="Band Disaster: `hostname` $BAND Mbps at `date`,swith to proxy."
		else
			STR="Band Disaster: `hostname` $BAND Mbps at `date`,keep at proxy."
			sysctl -p
		fi
	else
		STR="Band Warn: `hostname` $BAND Mbps at `date`"
		sysctl -p
	fi
	echo $STR >> /tmp/band_warning.log
	send_fetion $mobile_num "$STR"
fi
