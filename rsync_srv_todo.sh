#!/bin/sh
# added by geminis 2010/11/05
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg

readonly KEY="/root/.ssh/53kf-server.ssh"
readonly LIST="/root/.ssh/ip"

### Color setting
RED_COL="\\033[1;31m"  # red color
GREEN_COL="\\033[32;1m"     # green color
BLUE_COL="\\033[34;1m"    # blue color
YELLOW_COL="\\033[33;1m"         # yellow color
NORMAL_COL="\\033[0;39m"

### action defination
SLEEP="1"
DO="ssh -i $KEY -n"
#CMD="chkconfig gearmand on"
CMD="/etc/init.d/php-fpm reload"

while read LINE;do
	echo "$LINE"|grep -q "^#" 
	[ $? = 0 ] && continue

	IP=`echo $LINE|awk '{print $1}'`
	HOST=`echo $LINE|awk '{print $2}'`
	if [ ! -z $IP ];then
		echo -e "$GREEN_COL|---> $HOST ($IP)   Action: $CMD $NORMAL_COL"
		METHOD=`echo $DO|awk '{print $1}'`
		case "$METHOD" in
			ssh)
				$DO $IP $CMD
				sleep $SLEEP
				;;
			scp)
				$DO $IP:$CMD
				sleep $SLEEP
				;;
			rsync)
				;;
			*)
				echo "not supported."
				exit 0
				;;
		esac
	fi
done < $LIST
