#!/bin/sh
FILE=/root/ip_apnic
#rm -f $FILE
#wget http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest -O $FILE
rm -rf /root/aa
 
grep 'apnic|CN|ipv4|' $FILE | cut -f 4,5 -d'|'|sed -e 's/|/ /g' | while read ip cnt
do
       echo $ip:$cnt
       mask=$(cat << EOF | bc | tail -1
 
pow=32;
define log2(x) {
if (x<=1) return (pow);
pow--;
return(log2(x/2));
}
 
log2($cnt)
EOF
)
       NETNAME=`whois $ip@whois.apnic.net | sed -e '/./{H;$!d;}' -e 'x;/netnum/!d' |grep ^netname | sed -e 's/.*:      \(.*\)/\1/g' | sed -e 's/-.*//g'|sed 's: ::g'`
 
	echo "$NETNAME" >> /root/aa
       case "$NETNAME" in
         CNC|CNCGROUP|UNICOM)
                echo $ip/$mask >> /root/CNC;;
         CHINATELECOM|CHINANET)
                echo $ip/$mask >> /root/CTC;;
         CRTC)
                echo $ip/$mask >> /root/CRTC;;
         *)
                echo "$ip/$mask $NETNAME" >> /root/OTHER;;
       esac
done
