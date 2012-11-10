#!/bin/sh
#LOAD=$(iostat -c|grep -v Linux|awk '/[0-9]/{print "scale=2;"$4"/"$3}'|bc)
NUM=`grep -c processor /proc/cpuinfo`
LIMIT=$(($NUM/1))
LOAD=$(iostat -c|grep -v Linux|awk '/[0-9]/{print $4}')

mobile_num="13666626825,13655813908"

send_fetion() {
        curl http://mon.53kf.com/f.php?phone="13655896157"\&pwd="reallyred520"\&to="$1"\&msg="$2"
}

BOOL=`echo "$LOAD<$LIMIT"|bc`

if [ $BOOL = 0 ];then
        send_fetion $mobile_num "CPU LOAD:`hostname` $LOAD at `date`"
fi
