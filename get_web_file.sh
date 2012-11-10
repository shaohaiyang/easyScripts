#!/bin/sh
DIR=`pwd`

[ -z "$1" ] && echo "input a log file." && exit 0

ERR="$PWD/bad_account.log"
awk -F~ '{if($4!~/200/ && $4!~/304/ && $4!~/301/ && $4!~/302/) print $0}' $1  > $ERR
