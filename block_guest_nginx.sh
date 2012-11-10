#!/bin/sh
NGINX_DIR="/opt/nginx/conf"
BLACKLIST=$NGINX_DIR"/stoplist"
NGINX_CONF=$(awk '/[ *][^#.*]include.*proxy/{print $2}' $NGINX_DIR"/nginx.conf")
NGINX_CONF=$NGINX_DIR"/"${NGINX_CONF%;}

reload(){
if [ -s $BLACKLIST ];then
	LINE=""
	while read bad;do
		bad=`echo "$bad"|awk -F"\t->" '{print $1}'|sed -r 's#\?#\\\?#g'`
		LINE=$LINE"$bad|"
	done < $BLACKLIST
	LINE=${LINE%|}

	sed -r -i "/stoplist/d" $NGINX_CONF
	echo -e "\tif ( \$request ~* \"$LINE\" ){\t# stoplist\n\t\treturn 444;\t# stoplist\n\t\tbreak; \t# stoplist\n\t}\t# stoplist" > /tmp/.tmp_blacklist
	sed -r -i "/bad referer/r /tmp/.tmp_blacklist" $NGINX_CONF
else
	echo "stoplist is empty or not exist."
	sed -r -i "/stoplist/d" $NGINX_CONF
fi

rm -rf /tmp/.tmp_blacklist
/etc/init.d/nginx reload
exit 0
}

REASON="No reason"
LIFE="86400" # a day

[ ! -z "$2" ] && LIFE=$2
[ ! -z "$3" ] && REASON=$3
if [ ! -z "$1" ];then
	URL=`echo $1|sed -r -e 's#(.*)&keyword.*#\1#g' -e 's#\?#\\\?#g'`
	sed -r -i "/$URL/d" $BLACKLIST
	echo -e "$URL\t-> `date`\t\"$REASON\"\t#`date +%s`@$LIFE" >> $BLACKLIST
fi

reload
