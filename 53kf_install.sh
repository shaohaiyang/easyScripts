#!/bin/sh
### Envirnoment setting
MASTER_ROLE="NO"
INIT_COPY="YES"

SERVICES="anacron crond haldaemon irqbalance messagebus network local sshd syslog mysqld nginx php-fpm php-daemon javacomet zabbix_agentd memcached gearmand"
LOCAL_GROUP="127.0.0.1|masterdb 6ddatabase.com 6ddatabase.com.ro kf.memserver talkSessionServer"
OTHER_GROUP="60.191.223.34|adminSessionServer agentSessionServer"
ZONE="Asia/Shanghai"
SSHD_PORT="22"
NGINX_PORT="80"
TIME_SRV="133.100.11.8"

DIR=`pwd`
### Color setting
RED_COL="\\033[1;31m"  # red color
GREEN_COL="\\033[32;1m"     # green color
BLUE_COL="\\033[34;1m"    # blue color
YELLOW_COL="\\033[33;1m"         # yellow color
NORMAL_COL="\\033[0;39m"

### Set hostname
if [ -z $1 ];then
	echo -n "Please input HostName(eg. ZZ-WWW13): "
	read HOST
else
	HOST=$1
fi
[ -z $HOST ] && HOST="TEST-SRV"

if [ -z $2 ];then
	echo -n "Please input Group DNS Name(eg. test.53kf.com):"
	read GID
else
	GID=$2
fi
[ -z $GID ] && GID="test.53kf.com"

hostname $HOST
sed -r -i '/HOSTNAME/d' /etc/sysconfig/network
echo "HOSTNAME=$HOST" >> /etc/sysconfig/network
sed -r -i "/$HOST/d" /etc/hosts
sed -r -i "/localhost.localdomain/d" /etc/hosts
echo "127.0.0.1               localhost.localdomain localhost $HOST" >> /etc/hosts

### set sendmail hostname
sed -r -i "/LOCAL_DOMAIN/s:.*:LOCAL_DOMAIN(\`$HOST')dnl:g" /etc/mail/sendmail.mc

export LC_ALL=C
grep -q "LC_ALL=C" /etc/profile || echo "export LC_ALL=C" >> /etc/profile
echo "alias cp=\"cp -a\"" >> /etc/bashrc
source /etc/profile

if [ ! -z "$LOCAL_GROUP" ];then
        IP=`echo $LOCAL_GROUP|cut -d'|' -f1`
        GROUP=`echo $LOCAL_GROUP|cut -d'|' -f2`
        for i in $GROUP;do
                #echo "127.0.0.1               $i" >> /etc/hosts
                sed -r -i "/$i/d" /etc/hosts
                echo "$IP               $i" >> /etc/hosts
        done
fi
if [ ! -z "$OTHER_GROUP" ];then
        IP=`echo $OTHER_GROUP|cut -d'|' -f1`
        GROUP=`echo $OTHER_GROUP|cut -d'|' -f2`
        [ $MASTER_ROLE = "YES" ] && IP="127.0.0.1"
        for i in $GROUP;do
                sed -r -i "/$i/d" /etc/hosts
                echo "$IP               $i" >> /etc/hosts
        done
fi

### enable intel network parameter
sed -r -i '/^$/d' /etc/rc.local
echo "" >> /etc/rc.local

sed -r -i '/iproute/d' /etc/rc.local
sed -r -i '/alias/d' /etc/rc.local
echo "alias cp=\"cp -a\"" >> /etc/rc.local
echo "" >> /etc/rc.local

echo "/usr/bin/iproute.sh " >> /etc/rc.local
echo "" >> /etc/rc.local

sed -r -i '/queue/d' /etc/rc.local
echo "echo \"1024\" > /sys/block/sda/queue/nr_requests" >> /etc/rc.local
echo "echo \"16\" > /sys/block/sda/queue/read_ahead_kb" >> /etc/rc.local

echo "" >> /etc/rc.local
sed -r -i '/for/,/done/d' /etc/rc.local
echo "for i in \`ifconfig |grep eth|awk '{print \$1}'\`;do" >> /etc/rc.local
echo "  ethtool -K \$i rx on" >>  /etc/rc.local
echo "  ethtool -K \$i tx on" >>  /etc/rc.local
echo "  ethtool -K \$i sg on" >>  /etc/rc.local
echo "  ethtool -K \$i tso on" >>  /etc/rc.local
echo "  ethtool -K \$i gso on" >>  /etc/rc.local
echo "  ethtool -K \$i gro on" >>  /etc/rc.local
echo "done" >> /etc/rc.local

echo "" >> /etc/rc.local
sed -r -i '/chown/d' /etc/rc.local
echo "chown -R nobody.nobody /home/{.nginx*,html}" >> /etc/rc.local
echo "chown -R mysql.mysql /home/mysql" >> /etc/rc.local

sed -r -i '/touch/d' /etc/rc.local
sed -r -i '/firewall/d' /etc/rc.local
sed -r -i '/sysctl/d' /etc/rc.local
sed -r -i '/rsync/d' /etc/rc.local
sed -r -i '/anti_ddos/d' /etc/rc.local
sed -r -i '/blacklist/d' /etc/rc.local
sed -r -i '/sleep/d' /etc/rc.local
sed -r -i '/watch/d' /etc/rc.local
sed -r -i '/upload_dir/d' /etc/rc.local
sed -r -i '/block_badip/d' /etc/rc.local
echo "#rsync --daemon" >> /etc/rc.local
echo "" >> /etc/rc.local
echo "#cp -a /etc/blacklist.txt /etc/blacklist.bak" >> /etc/rc.local
echo "#sort -n /etc/blacklist.txt |uniq > /tmp/ip.tmp" >> /etc/rc.local
echo "#cp -a /tmp/ip.tmp /etc/blacklist.txt" >> /etc/rc.local
echo "#/etc/firewall/firewall start # Own firewall scripts start" >> /etc/rc.local
echo "#/usr/bin/anti_ddos.sh" >> /etc/rc.local
echo "#/usr/bin/block_badip.sh" >> /etc/rc.local
echo "#sleep 1" >> /etc/rc.local
echo "sysctl -p" >> /etc/rc.local

echo "" >> /etc/rc.local
sed -r -i '/hunter/d' /etc/rc.local
echo "sleep 3" >> /etc/rc.local
echo "/usr/bin/hunter > /etc/issue" >> /etc/rc.local
echo "/usr/bin/hunter > /etc/issue.net" >> /etc/rc.local
echo "/usr/bin/hunter > /etc/motd" >> /etc/rc.local

echo "" >> /etc/rc.local
echo "/usr/bin/create_upload_dir.sh" >> /etc/rc.local
echo "touch /var/lock/subsys/local" >> /etc/rc.local

### check system envirnoment
begin(){
	echo -en "$GREEN_COL================ "
	printf "%25s" "$1"
	echo -e " ================$NORMAL_COL"
}
sub_menu(){
	echo -n "------- "
	printf "%-20s" "$1"
	echo " ------- "
}

end(){
	echo "================================================"
}

begin "Check user security"
sub_menu "Who's UID = 0"
awk  -F: '($3==0||$4==0) {print $0}' /etc/passwd|grep bash --color
sub_menu "Who has /bin/bash"
grep "bash" /etc/passwd --color
sub_menu "Modify it ."
sed -r -i '/^[^root]/s:/bin/bash:/sbin/nologin:g' /etc/passwd
grep "bash" /etc/passwd --color
sub_menu "Check init level"
grep "^id" /etc/inittab --color
LEV=`grep "^id" /etc/inittab |awk -F: '{print $2}'`
        if [ $LEV -ne 3 ];then
		sub_menu "Change init to 3 level"
                sed -r -i '/^id/s/.*/id:3:initdefault:/g' /etc/inittab
        fi
echo 

### Install necessary software
if [ `uname -i` = "x86_64" ];then
	sed -r -i '/exclude/d' /etc/yum.conf
	echo "exclude=*.i?86" >> /etc/yum.conf
fi

rpm -e geoip --nodeps
yum install -y iptraf xinetd libmcrypt ntp screen e4fsprogs libtool-ltdl MySQL-python python-setuptools.noarch GeoIP GeoIP-data

begin "Install Mysql(Server),Java(Openjdk)"
rpm -qa|grep mysql-server -q
if [ $? = 0 ] ;then
	echo "Mysql server installed."
else
	yum install -y mysql mysql-server
fi
rpm -qa|grep openjdk -q
if [ $? = 0 ] ;then
	echo "Java JDK installed."
else
	yum install -y java-1.6.0-openjdk
fi
echo

### check system services
begin "Check system running services"
for i in /etc/rc3.d/S*;do
        prog=$(echo `basename $i`|cut -c4-)
        echo "$SERVICES"|grep -q $prog
        [ $? != 0 ] && echo "$prog disabled" && chkconfig $prog off
done

df|grep -q mapper
[ $? = 0 ] && SERVICES=$SERVICES" lvm2-monitor"
for i in $SERVICES;do
        chkconfig $i on
done
echo

### disable selinux
begin "Disable selinux"
sed -r -i '/^SELINUX=/s:.*:SELINUX=disabled:' /etc/sysconfig/selinux

### turn on system parametre
if [ $INIT_COPY = "YES" ];then
        cp -a $DIR/home/* /home/
        cp -a $DIR/sbin/* /sbin/
        cp -a $DIR/usr/* /usr/
        cp -a $DIR/etc/* /etc/
        cp -a $DIR/opt/* /opt/
        cp -a $DIR/lib/* /lib/
fi
chmod a+x /usr/bin/*

### Ext4 formatting
begin "Format /home partion"
PARTITION=`df -h|grep home|awk '{print $1}'`
file -s $PARTITION|grep -q ext4
if [ ! $? = 0 ];then
	umount -f /home
	mkfs.ext4 $PARTITION
fi
e4label $PARTITION /home 
sed -r -i '/home/s#(.*)=.*(/home.*)ext.*defaults.*#\1=/home\t\t\2ext4\tdefaults,noatime,nodiratime,barrier=0\t1 2#' /etc/fstab
mount -a
sleep 1

### Mysql setting again
begin "Mysql setting."
mkdir -p /home/mysql
chown -R mysql.mysql /home/mysql
[ -L /var/lib/mysql ] || mv /var/lib/mysql /var/lib/mysql.old
ln -snf /home/mysql /var/lib/mysql
MASTER_PORT=`sed -r -n '/MASTER_PORT=/s@.*="(.*)"@\1@gp' /etc/53kf.cfg`
sed -r -i "/^port=/s:.*:port=$MASTER_PORT:g" /etc/my.cnf

### HTML document setting
mkdir -p /home/html
mkdir -p /home/.nginx-spool
chown -R nobody.nobody /home/.nginx-spool
chown -R nobody.nobody /home/html

### scws setting
[ -L /usr/local/scws ] || mv /usr/local/scws /usr/local/scws.old
ln -snf /opt/scws /usr/local/scws

[ -d /var/lib/GeoIP ] || mkdir -p /var/lib/GeoIP
[ -d /usr/share/GeoIP ] || mkdir -p /usr/share/GeoIP
ln -snf /home/GeoLiteCity.dat /var/lib/GeoIP/GeoIPCity.dat
ln -snf /var/lib/GeoIP/GeoIPCity.dat /usr/share/GeoIP/

### Zabbix setting
begin "Zabbix added user"
grep -q -w zabbix /etc/passwd
[ $? = 1 ] && useradd -s /sbin/nologin -d /dev/null zabbix

### update system library path
ldconfig

### install aide file check
begin "Install AIDE"
if [ -x /usr/sbin/aide ];then
	echo "aide is running."
else
	yum install aide -y
fi
echo 

begin "Ajust system parameter"
sed -r -i 's:timeout=.*:timeout=3:' /boot/grub/menu.lst
grep -q "elevator=deadline" /boot/grub/menu.lst
[ $? = 0 ] || sed -r -i '/^[^#]kernel/s:(.*):\1 elevator=deadline:' /boot/grub/menu.lst 

rm -rf /etc/cron.daily/{cups,makewhatis.cron,mlocate.cron,prelink,rpm,tmpwatch}
rm -rf /etc/cron.hourly/mcelog.cron
rm -rf /etc/cron.weekly/{99-raid-check,makewhatis.cron}
rm -rf /etc/cron.d/sysstat

grep -q "Pollux" /etc/userlist.txt || echo "geminisshao@audividi.com,Pollux" >> /etc/userlist.txt

begin "Ajust Nginx parameter"
sed -r -i "/NGINX_PORT=/s:.*:NGINX_PORT=\"$NGINX_PORT\":g" /etc/rc.d/init.d/nginx
if [ $MASTER_ROLE = "YES" ];then
    sed -r -i '/Virtual Master/,/End Master/s:^#([^#].*):\1:g' /opt/nginx/conf/config/servers.conf
    sed -r -i "/server_name/d" /opt/nginx/conf/config/servers.conf
    sed -r -i "/server_name/d" /opt/nginx/conf/config/static.conf
    sed -r -i "/master/i\\\tserver_name $GID;" /opt/nginx/conf/config/servers.conf
    sed -r -i '/\$uri \~/,/}/d' /opt/nginx/conf/config/proxy_*
    PRE=`echo $GID|awk -F"." '{print $1}' `
    DOMAIN=${GID#$PRE}
    sed -r -i "/talk/i\\\tserver_name $PRE"1"$DOMAIN;" /opt/nginx/conf/config/servers.conf
    sed -r -i "/talk/i\\\tserver_name $PRE"1"$DOMAIN;" /opt/nginx/conf/config/static.conf
else
    sed -r -i '/Virtual Master/,/End Master/s:^([^#].*):#\1:g' /opt/nginx/conf/config/servers.conf
    sed -r -i "/server_name/d" /opt/nginx/conf/config/servers.conf
    sed -r -i "/talk/i\\\tserver_name $GID;" /opt/nginx/conf/config/servers.conf
fi

### check the network setting and record it
/usr/bin/hunter > /etc/issue
/usr/bin/hunter > /etc/issue.net
/usr/bin/hunter > /etc/motd

begin "Install Mysql-python"
/usr/bin/easy_install pyExcelerator
sleep 1

echo "sysctl -p"
sysctl -p  > /dev/null
echo

begin "Check sshd daemon"
sed -r -i '/UseDNS/s:.*:UseDNS no:' /etc/ssh/sshd_config
sed -r -i '/TCPKeepAlive/s:.*:TCPKeepAlive yes:' /etc/ssh/sshd_config
sed -r -i '/ClientAliveInterval/s:.*:ClientAliveInterval 3:' /etc/ssh/sshd_config
sed -r -i '/MaxAuthTries/s:.*:MaxAuthTries 3:' /etc/ssh/sshd_config
echo 

### set timezone and language
grep -w -q $ZONE /etc/sysconfig/clock
if [ $? = 1 ];then
        sed -r -i "s:ZONE=.*:ZONE=\"$ZONE\":" /etc/sysconfig/clock
        cp -a /usr/share/zoneinfo/$ZONE /etc/localtime
fi
begin "Ajust timezone "
        ntpdate -o3 $TIME_SRV
echo

begin "Ajust system limits "
	sed -r -i '/nofile/d' /etc/security/limits.conf
	echo '* soft nofile 655350' >> /etc/security/limits.conf 
	echo '* hard nofile 655350' >> /etc/security/limits.conf
	echo '#* soft memlock 104857' >> /etc/security/limits.conf
	echo '#* hard memlock 104857' >> /etc/security/limits.conf
echo
end
