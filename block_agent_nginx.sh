#!/bin/sh
NGINX_DIR="/opt/nginx/conf"
BLACKLIST=$NGINX_DIR"/agentlist"
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
	echo "	if ( \$http_user_agent ~ ($LINE) ){   # agentlist" > .temp
	echo "# agentlist badlist" >> .temp

	sed -r -i "/agentlist/d" $NGINX_CONF

	sed -r -i "/robots/r .temp" $NGINX_CONF
	sed -r -i "/badlist/i\ \t\treturn 444;\t# agentlist\n\t\tbreak; \t# agentlist\n\t}\t# agentlist" $NGINX_CONF
	rm -rf .temp
else
	echo "agentlist is empty or not exist."
	sed -r -i "/agentlist/d" $NGINX_CONF
fi

/etc/init.d/nginx reload
exit 0
}

REASON="No reason"
LIFE="86400" # a day

[ ! -z "$2" ] && LIFE=$2
[ ! -z "$3" ] && REASON=$3
if [ ! -z "$1" ];then
    sed -r -i "/$1/d" $BLACKLIST
    echo -e "$1\t-> `date`\t\"$REASON\"\t#`date +%s`@$LIFE" >> $BLACKLIST
fi

reload
