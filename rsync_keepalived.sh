#!/bin/sh
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg
chkconfig keepalived off

KEEPALIVED_CONF="/opt/keepalived/etc/keepalived.conf"
SSHD="ssh -i /root/.ssh/53kf-server.ssh"
DEV=`/sbin/ip add |grep "192\.168\.0\."|sed -r 's:.*eth(.*):eth\1:g'`

LIST="/etc/53kf.cfg \
	/opt/ \
	/etc/hosts \
	/etc/sysctl.conf \
        /etc/profile \
	/etc/exports \
	/etc/cron.d/53kf \
	/etc/rc.d/ \
	/etc/firewall/ \
	/home/html/ \
	/home/GeoLiteCity.dat \
	/var/share/ 
	"

for i in $LIST;do
    rsync -avz --delete -e "$SSHD" $KEEPALIVED_MASTER:$i $i
done

rsync -avz --delete -e "$SSHD" $KEEPALIVED_MASTER:/etc/my.cnf /etc/my.cnf.master

PRI=$(awk '/priority/{print $2}' $KEEPALIVED_CONF|sort|uniq)

sed -r -i "s:KEEPALIVED_MASTER=.*:KEEPALIVED_MASTER=\"$KEEPALIVED_MASTER\":g" /etc/53kf.cfg
sed -r -i "s:priority.*:priority $((PRI-5)):g" $KEEPALIVED_CONF
sed -r -i "/MASTER/s:MASTER:BACKUP:g" $KEEPALIVED_CONF

sed -r -i "/VI_2/,/interface/{s:eth.*:$DEV:g}" $KEEPALIVED_CONF
sed -r -i "/VI_2/,/label/{s#$MASTER_HOST.*#$MASTER_HOST label $DEV:1#g}" $KEEPALIVED_CONF
