#!/bin/sh
# added by geminis 2010/11/05
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg

SIZE=8192
NFS_DIR="/var/share/www/upload@/home/html/talk/www/upload \
	/var/share/www/download@/home/html/talk/www/download \
	/var/share/www/img/upload@/home/html/talk/www/img/upload \
	/var/share/scws@/home/html/talk/scws"
for i in $NFS_DIR;do
        DIR=`echo $i|cut -d@ -f1`
        DST=`echo $i|cut -d@ -f2`

        [ -L $DST ] && rm -rf $DST
        mkdir -p $DST
        mount -t nfs -o rsize=$SIZE,wsize=$SIZE,udp $MASTER_HOST:$DIR $DST
done

