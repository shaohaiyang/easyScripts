#!/bin/sh
PWD=`pwd`

gen_cnc(){
FILE=$PWD/CNC

#rm -rf  $FILE.tmp
while read LINE;do
	echo "$LINE"
	echo -n "$LINE @ " >> $FILE.tmp
	whois $LINE|egrep "address"|xargs echo >> $FILE.tmp
	echo  "-----------------"  >> $FILE.tmp
	sleep 1
done < $FILE

egrep -i "Mongolia|Cordelia|JPNIC|Beijing|Hebei|Langfang|TIANJIN|Jilin|Shijiazhuang|Jian Heng|Shenyang|Liaoning" $FILE.tmp > Huabei.cnc
egrep -i -v "Mongolia|Cordelia|JPNIC|Beijing|Hebei|Langfang|TIANJIN|Jilin|Shijiazhuang|Jian Heng|Shenyang|Liaoning" $FILE.tmp > aaa
mv aaa $FILE.tmp

egrep -i "Henan|Zhenzhou|he nan" $FILE.tmp > Huazhong.cnc
egrep -i -v "Henan|Zhenzhou|he nan" $FILE.tmp > aaa
mv aaa $FILE.tmp

egrep -i "GuangDe|Chengdu|Taiyuan|Shanxi" $FILE.tmp > Xi.cnc
egrep -i -v "GuangDe|Chengdu|Taiyuan|Shanxi" $FILE.tmp > aaa
mv aaa $FILE.tmp

egrep -i "Qingdao|Hangzhou|pudong|Ningbo|Nanchang|ZheJiang|Shanghai|Jiangsu" $FILE.tmp > Huadong.cnc
egrep -i -v "Qingdao|Hangzhou|pudong|Ningbo|Nanchang|ZheJiang|Shanghai|Jiangsu" $FILE.tmp > aaa
mv aaa $FILE.tmp

egrep -i "Meizhou|guangxi|ShenZhen|ZhuHai|Guangzhou|Guangdong|Guang Zhou|SHUNDE|FOSHAN|GUANG DONG" $FILE.tmp > Huanan.cnc
egrep -i -v "Meizhou|guangxi|ShenZhen|ZhuHai|Guangzhou|Guangdong|Guang Zhou|SHUNDE|FOSHAN|GUANG DONG" $FILE.tmp > aaa
mv aaa $FILE.tmp

sed -r -i '/-----/d' $FILE.tmp
cat $FILE.tmp >> Huabei.cnc
sed -r -i 's#@.*##g' H*.cnc
sed -r -i 's#@.*##g' Xi.cnc
}

gen_ctc(){
FILE=$PWD/OTHER

#rm -rf  $FILE.tmp
while read LINE;do
	echo "$LINE"
	echo -n "$LINE @ " >> $FILE.tmp
	whois $LINE|egrep "address"|xargs echo >> $FILE.tmp
	echo  "-----------------"  >> $FILE.tmp
	sleep 1
done < $FILE

egrep -i "Mongolia|Cordelia|JPNIC|Beijing|Hebei|Langfang|TIANJIN|Jilin|Shijiazhuang|Jian Heng|Shenyang|Liaoning" $FILE.tmp > Huabei.ctc
egrep -i -v "Mongolia|Cordelia|JPNIC|Beijing|Hebei|Langfang|TIANJIN|Jilin|Shijiazhuang|Jian Heng|Shenyang|Liaoning" $FILE.tmp > aaa
mv aaa $FILE.tmp

egrep -i "Henan|Zhenzhou|he nan" $FILE.tmp > Huazhong.ctc
egrep -i -v "Henan|Zhenzhou|he nan" $FILE.tmp > aaa
mv aaa $FILE.tmp

egrep -i "GuangDe|Chengdu|Taiyuan|Shanxi" $FILE.tmp > Xi.ctc
egrep -i -v "GuangDe|Chengdu|Taiyuan|Shanxi" $FILE.tmp > aaa
mv aaa $FILE.tmp

egrep -i "Qingdao|Hangzhou|pudong|Ningbo|Nanchang|ZheJiang|Shanghai|Jiangsu" $FILE.tmp > Huadong.ctc
egrep -i -v "Qingdao|Hangzhou|pudong|Ningbo|Nanchang|ZheJiang|Shanghai|Jiangsu" $FILE.tmp > aaa
mv aaa $FILE.tmp

egrep -i "Meizhou|guangxi|ShenZhen|ZhuHai|Guangzhou|Guangdong|Guang Zhou|SHUNDE|FOSHAN|GUANG DONG" $FILE.tmp > Huanan.ctc
egrep -i -v "Meizhou|guangxi|ShenZhen|ZhuHai|Guangzhou|Guangdong|Guang Zhou|SHUNDE|FOSHAN|GUANG DONG" $FILE.tmp > aaa
mv aaa $FILE.tmp

sed -r -i '/-----/d' $FILE.tmp
cat $FILE.tmp >> Huadong.ctc
sed -r -i 's#@.*##g' H*.ctc
sed -r -i 's#@.*##g' Xi.ctc
}

gen_cnc
gen_ctc
