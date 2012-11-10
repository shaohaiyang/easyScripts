#!/bin/sh
URL="http://www.jiankongbao.com/tool_dispose.php"
OUTPUT="$2/$1.html"
POST="-d host=$1&__action=tool_ping"

curl -s $POST $URL -o $OUTPUT
sed -r -i 's^</script>^</scripts>\n^g' $OUTPUT
awk -F, '{print $1$3}' $OUTPUT > /tmp/server_check.log

sed -r -e "/finish/d" -e "s:'::g" /tmp/server_check.log |awk -F'(' '{print $2}'|sort -k1n|sed -r 's@.*<span .*>(.*) ms</span>$@\1@g' >      $OUTPUT

DATE=`date`
echo "$DATE   `sed -n '1p' $OUTPUT`" >> /tmp/$1_xian_ctc
echo "$DATE   `sed -n '2p' $OUTPUT`" >> /tmp/$1_dalian_cnc
echo "$DATE   `sed -n '3p' $OUTPUT`" >> /tmp/$1_shenzhen_ctc
echo "$DATE   `sed -n '4p' $OUTPUT`" >> /tmp/$1_beijing_cnc
echo "$DATE   `sed -n '5p' $OUTPUT`" >> /tmp/$1_zhejiang_ctc
echo "$DATE   `sed -n '6p' $OUTPUT`" >> /tmp/$1_jinan_cnc

