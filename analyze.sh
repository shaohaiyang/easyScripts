#!/bin/sh
# $7 = Cardinality
awk '{if($0~/table/) print "\n"$4; else print $7;}' $1 > $1.log
