#!/bin/sh
LOG="/var/log/nginx/access.log.2010120912"
[ -z "$1" ] || KEYWORD=`echo "$1" | sed -r -e 's:%:%25:g' -e 's#:#%3A#g' -e 's:\?:%3F:g' -e 's:=:%3D:g' -e 's:\/\/:/:g' -e 's:&:%26:g' -e 's:\/:\.\*:g'`
ACCOUNT=$2
[ -z "$3" ] || REFERER=`echo "$3" | sed -r -e 's:%:%25:g' -e 's#:#%3A#g' -e 's:\?:%3F:g' -e 's:=:%3D:g' -e 's:\/\/:/:g' -e 's:&:%26:g' -e 's:\/:\.\*:g'`

[ -z $ACCOUNT ] || URL="arg=$ACCOUNT.*"
[ -z $REFERER ] || URL=$URL"&referer=$REFERER.*"
[ -z $KEYWORD ] || URL=$URL"&keyword=$KEYWORD"

grep "$URL" $LOG | sed -r -e 's:.*webCompany.php?(.*)HTTP.*:\1:g' | sort |uniq -c|sort -k1
