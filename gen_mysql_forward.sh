#!/bin/sh
start() {
        ssh -CNfg -L 3308:localhost:3306 192.168.111.125
}

stop() {
        PID=`ps -auxf|grep "CNfg"|grep -v grep |awk '{print $2}'`
        for i in $PID;do
                kill -9 $i
        done
}

case $1 in
        start)
                start
                ;;
        stop)
                stop
                ;;
        *)
                echo "$0 {start|stop}"
                ;;
esac

