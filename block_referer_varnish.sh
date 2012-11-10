#!/bin/sh
VARNISH_DIR="/opt/varnish"
BLACKLIST=$VARNISH_DIR"/blacklist"
VARNISH_CONF=$VARNISH_DIR"/etc/default.vcl"
REASON="no reason"
TMP="/tmp/.varnish.tmp"

reload(){
if [ -s $BLACKLIST ];then
        LINE=""
        STRING=""
        sed -r -i "/^$/d" $BLACKLIST
        while read bad;do
                mark=`echo "$bad"|awk '{print $1}'`
                bad=`echo "$bad"|awk '{print $2}'`
                case $mark in
                        ref)
                                LINE="\t\t|| req.http.referer ~ \"$bad\" \t\t# blacklist\n";;
                        ip)
                                LINE="\t\t|| client.ip == \"$bad\" \t\t# blacklist\n";;
                        agt)
                                LINE="\t\t|| req.http.user-agent ~ \"$bad\" \t# blacklist\n";;
                        url)
                                LINE="\t\t|| req.url ~ \"$bad\" \t\t\t# blacklist\n";;
                esac
                STRING=$STRING$LINE
        done < $BLACKLIST
        STRING="\tif ( req.http.user-agent ~ \"^$\" \t\t# blacklist\n$STRING\t) {\t\t\t\t\t\t# blacklist\n\t\terror 403 \"Not Allowed.\";\t\t# blacklist\n\t}\t\t\t\t\t\t# blacklist\n"
        echo -en $STRING > $TMP

    sed -r -i "/blacklist/d" $VARNISH_CONF
    sed -r -i "/vcl_recv/r $TMP" $VARNISH_CONF
else
    echo "blacklist is empty or not exist."
    sed -r -i "/blacklist/d" $VARNISH_CONF
fi

rm -rf $TMP
exit 0
}

case $1 in
	ref)
		STRING="ref\t$2";;
	ip)
		STRING="ip\t$2";;
	agt)
		STRING="agt\t$2";;
	url)
		STRING="url\t$2";;
	reload)
		reload;;
	*)
		echo "input  ref,ip,agt,url,reload"
		exit 0;;
esac

[ -z "$2" ] && (echo "Usage: $0 (ref|ip|agt|url|reload) param some-reson") && exit 0
[ ! -z "$3" ] && REASON=$2

[ -s $BLACKLIST ] || touch $BLACKLIST
sed -r -i "/$2/d" $BLACKLIST
echo -e "$STRING\t#`date`\t\"$REASON\"\n" >> $BLACKLIST

reload
