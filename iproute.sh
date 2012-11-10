#!/bin/sh
# Defalut device to gateway!!!
DEF_DEV=`cat /etc/policy_start`
[ -z $DEF_DEV ] && DEF_DEV="eth0"

ROUTE=$(ip ro|grep default|sort -u|sed -n "/$DEF_DEV/!p")
if [ ! -z "$ROUTE" ];then
        for i in "$ROUTE";do
                ip ro del $i
        done
fi

DEF_GW=`grep GATEWAY /etc/sysconfig/network-scripts/ifcfg-$DEF_DEV|cut -d= -f2`
ip ro re default via $DEF_GW dev $DEF_DEV
ip ro fl ca
