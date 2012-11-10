#!/bin/sh
readonly Proxy_CFG="/etc/squid/squid.conf"

if [ -z "$1" -o -z "$2" ];then
        echo "$0 www1 realip | del"
else
        HOST="$1"_server

        # clean old items
        sed -r -i "/$1[^0-9]/d" $Proxy_CFG
        sed -r -i "/$HOST/d" $Proxy_CFG
        sed -r -i "/$HOST/d" /etc/hosts

        [ "$2" = "del" ] && exit 0

        # clean and added hosts lookup
        echo -e "$2\t$HOST" >> /etc/hosts

        # squid configure
        sed -r -i "/cache_peer shaohy/i\cache_peer $HOST parent 80 0 no-query originserver" $Proxy_CFG
        sed -r -i "/acl shaohy/i\acl $1 url_regex -i ^http:\/\/$1\/\.\*\$" $Proxy_CFG
        sed -r -i "/cache_peer_access shaohy/i\################################ $HOST" $Proxy_CFG
        sed -r -i "/cache_peer_access shaohy/i\cache_peer_access $HOST deny banlist" $Proxy_CFG
        sed -r -i "/cache_peer_access shaohy/i\cache_peer_access $HOST allow $1" $Proxy_CFG
        sed -r -i "/cache_peer_access shaohy/i\cache_peer_access $HOST deny all" $Proxy_CFG
        sed -r -i "/cache_peer_access shaohy/i\################################ $HOST" $Proxy_CFG
fi

