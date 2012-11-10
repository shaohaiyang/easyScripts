#!/bin/sh
netstat -nt | grep -v "127.0.0.1"|awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
