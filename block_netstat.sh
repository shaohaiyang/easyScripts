#!/bin/sh
DEFINE="ESTABLISH#15#80 FIN_WAIT1#35#80 SYN_RECV#20#80"

for i in $DEFINE;do
        STATE=`echo $i|cut -d# -f1`
        NUM=`echo $i|cut -d# -f2`
        PORT=`echo $i|cut -d# -f3`

        if [ -z $PORT ];then
        netstat -nt|awk '/'"$STATE"'/{print $5}'|sed -r -e 's/::ffff://g' -e 's/([0-9].*):[0-9]*/\1/g'|awk '{++S[$1]} END{for(a in S) \
        if( system("grep -q "a" /etc/whitelist.txt" ) != 0 && S[a]>'$NUM' ) print a" "S[a]" ""'$STATE'"" "'$NUM'}'| \
        xargs -i[] /usr/bin/record_ddos.sh []
        else
        netstat -nt|awk '/'":$PORT"' .* '"$STATE"'/{print $5}'|sed -r -e 's/::ffff://g' -e 's/([0-9].*):[0-9]*/\1/g'|awk '{++S[$1]} END{for(a in S) \
        if( system("grep -q "a" /etc/whitelist.txt" ) != 0 && S[a]>'$NUM' ) print a" "S[a]" ""'$STATE'"" "'$NUM'}'| \
        xargs -i[] /usr/bin/record_ddos.sh []
        fi
done

