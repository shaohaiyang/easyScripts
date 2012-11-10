#!/bin/sh
modprobe aoe
sleep 1

MOUNT="1#/home/html/talk/www/upload 2#/home/html/talk/www/download"

for LINE in $MOUNT;do
        echo "$LINE" |grep -q ^#
        [ $? = 0 ] && continue

        POINT=`echo $LINE|cut -d# -f1`
        DIR=`echo $LINE|cut -d# -f2`
        DEV="/dev/etherd/e0.$POINT"
        echo $DEV $DIR

        file -s $DEV |grep -q filesystem
        [ $? != 0 ] && mkfs.ext4 $DEV
        mount -t ext4 $DEV $DIR
done

