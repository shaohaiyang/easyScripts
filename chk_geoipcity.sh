#!/bin/sh
TAR="/home/GeoLiteCity.dat.gz"
wget -t 5 -O $TAR http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
gzip -d $TAR
