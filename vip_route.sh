#!/bin/sh
# Defalut device to gateway!!!
ACTION="add"

###########################################################################
get_network () {
        echo $@ | awk 'BEGIN{FS="[./]";OFS="."} END{ print and($1,$5),and($2,$6),and($3,$7),and($4,$8) }'
}
###########################################################################
##
## eth1_TAB AND eth0_TAB from /etc/iproute2/rt_tables
## E.G # echo 200 cnc >> /etc/iproute2/rt_tables
##     # echo 201 ctc >> /etc/iproute2/rt_tables
##
eth0_DEVICE=eth0:2
eth0_NAME=CTC
eth0_TAB=200
eth0_IPADDR=115.236.19.68
eth0_MK=255.255.255.255
eth0_GATEWAY=115.236.19.65
eth0_NETWORK=`get_network $eth0_IPADDR/$eth0_MK`

eth1_DEVICE=eth0:3
eth1_NAME=CNC
eth1_TAB=201
eth1_IPADDR=124.160.126.244
eth1_MK=255.255.255.255
eth1_GATEWAY=124.160.126.240
eth1_NETWORK=`get_network $eth1_IPADDR/$eth1_MK`

sed  -i '/CTC/d' /etc/iproute2/rt_tables
sed  -i '/CNC/d' /etc/iproute2/rt_tables
echo "$eth0_TAB $eth0_DEVICE # $eth0_NAME" >> /etc/iproute2/rt_tables
echo "$eth1_TAB $eth1_DEVICE # $eth1_NAME" >> /etc/iproute2/rt_tables

ip route flush table  ${eth1_TAB}
ip route ${ACTION} ${eth1_NETWORK} dev ${eth1_DEVICE} src ${eth1_IPADDR} table ${eth1_TAB}
ip route ${ACTION} default via ${eth1_GATEWAY} table ${eth1_TAB}

ip route flush table  ${eth0_TAB}
ip route ${ACTION} ${eth0_NETWORK} dev ${eth0_DEVICE} src ${eth0_IPADDR} table ${eth0_TAB}
ip route ${ACTION} default via ${eth0_GATEWAY} table ${eth0_TAB}

ip rule ${ACTION} from ${eth1_IPADDR} table ${eth1_TAB} prio ${eth1_TAB}
ip rule ${ACTION} from ${eth0_IPADDR} table ${eth0_TAB} prio ${eth0_TAB}

ip ro fl ca
