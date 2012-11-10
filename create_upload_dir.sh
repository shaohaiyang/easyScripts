#!/bin/sh
DIR="files mail snapshot"
HOME="/home/html/talk/www/upload"
HOME2=`awk '/upload/{print $1}' /etc/exports`

for i in $DIR;do
        if [ $i = "files" ];then
                for j in `seq 0 6`;do
                        mkdir -p $HOME/$i/company/$j
                        mkdir -p $HOME2/$i/company/$j
                done
                mkdir -p $HOME/$i/company_bg
                mkdir -p $HOME2/$i/company_bg
        elif [ $i = "snapshot" ];then
                for j in `seq 0 31`;do
                        mkdir -p $HOME/$i/$j
                        mkdir -p $HOME2/$i/$j
                done
        else
                mkdir -p $HOME/$i
                mkdir -p $HOME2/$i
        fi
done
chown -R nobody.nobody $HOME
chown -R nobody.nobody $HOME2

