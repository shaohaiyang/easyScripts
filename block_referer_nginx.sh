#!/bin/sh
NGINX_DIR="/opt/nginx/conf"
BLACKLIST=$NGINX_DIR"/blacklist"
NGINX_CONF=$(awk '/[ *][^#.*]include.*proxy/{print $2}' $NGINX_DIR"/nginx.conf")
NGINX_CONF=$NGINX_DIR"/"${NGINX_CONF%;}

reload(){
if [ -s $BLACKLIST ];then
        LINE=""
        while read bad;do
                bad=$(echo "$bad"|awk -F"\t->" '{print $1}'|sed -r -e 's: :\\x20:g' -e 's:;:\\;:g' -e 's:\(:\\(:g' -e 's:\):\\):g')
                LINE=$LINE"$bad|"
        done < $BLACKLIST
        LINE=${LINE%|}
        echo "  if ( \$http_referer ~ ($LINE) ){   # blacklist" > .temp
        echo "# blacklist badreferer" >> .temp

	sed -r -i "/blacklist/d" $NGINX_CONF
        sed -r -i "/bad referer/r .temp" $NGINX_CONF
	sed -r -i "/badreferer/i\ \t\treturn 444;\t# blacklist\n\t\tbreak; \t# blacklist\n\t}\t# blacklist" $NGINX_CONF
        rm -rf .temp
else
	echo "blacklist is empty or not exist."
	sed -r -i "/blacklist/d" $NGINX_CONF
fi
/etc/init.d/nginx reload
exit 0
}

REASON="No reason"
LIFE="86400" # a day

[ ! -z "$2" ] && LIFE=$2
[ ! -z "$3" ] && REASON=$3
if [ ! -z "$1" ];then
    URL=`echo $1|sed -r 's#(.*)&keyword.*#\1#g'`
    URL2=`echo $1|sed -r 's#.*\?(.*)#\1#g'`
    sed -r -i "/$URL/d" $BLACKLIST
    echo -e "$URL2\t-> `date`\t\"$REASON\"\t#`date +%s`@$LIFE" >> $BLACKLIST
fi

reload
