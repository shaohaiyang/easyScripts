#!/bin/bash
[ -s /etc/53kf.cfg ] && source /etc/53kf.cfg

#
# This script checks if a mysql server is healthy running on localhost. It will
# return:
#
# "HTTP/1.x 200 OK\r" (if mysql is running smoothly)
#
# "HTTP/1.x 500 Internal Server Error\r" (else)
#

MYSQL_PORT=`grep ^port /etc/my.cnf |cut -d= -f2`
#
# We perform a simple query that should return a few results
ERROR_MSG=`mysql -P$MYSQL_PORT -u$MYSQL_USER -p$MYSQL_PASS -e "show databases;" 2>/dev/null`
#
# Check the output. If it is not empty then everything is fine and we return
# something. Else, we just do not return anything.
#
if [ "$ERROR_MSG" != "" ]
then
        # mysql is fine, return http 200
        /bin/echo -e "HTTP/1.1 200 OK\r\n"
        /bin/echo -e "Content-Type: Content-Type: text/plain\r\n"
        /bin/echo -e "\r\n"
        /bin/echo -e "MySQL is running.\r\n"
        /bin/echo -e "\r\n"
else
        # mysql is down, return http 503
        /bin/echo -e "HTTP/1.1 503 Service Unavailable\r\n"
        /bin/echo -e "Content-Type: Content-Type: text/plain\r\n"
        /bin/echo -e "\r\n"
        /bin/echo -e "MySQL is *down*.\r\n"
        /bin/echo -e "\r\n"
fi
