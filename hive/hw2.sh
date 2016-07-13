#!/bin/bash

echo "begin"

# 需要跳过第一行
cat /data/hive_homework_data/demographic.csv | while read line
do
	user_line=`expr substr "$line" 2 32`
	echo $user_line
	echo $user_line >> users.txt
done

# 随机选取60个用户，建立60张表
echo "create 60 tables..."
for i in $(seq 1 60)
do
	echo "create user_web$i"
	num=`expr $RANDOM % 1000`
	line=`expr $num + 1`
	echo $line
	con=$(sed -n "$line"p users.txt)
	echo $con >> randusers.txt
	echo "create table if not exists jipeng.user_web${i} (urlstr string) partitioned by(uid string);" >> create_users.sql
	echo "insert overwrite table jipeng.user_web${i} partition(uid = '${con}') select urlstr from jipeng.mtb where urlstr != 'none' and uid = '${con}';" >> create_users.sql
done

echo "creating..."
hive -f ./create_users.sql

# 30对用户共同访问的网站
echo "generate 30 pairs record"
echo "use jipeng;" >> create_pairs.sql
for j in $(seq 1 30)
do
	echo "generate $j pair..."
	n=`expr $j \* 2`
	m=`expr $n - 1`
	echo "select t.urlstr,count(*) as urlnum from (select u${m}.urlstr as urlstr from user_web${m} as u${m} join user_web${n} as u${n} on (u${m}.urlstr=u${n}.urlstr)) t group by t.urlstr order by urlnum desc limit 3;" >> create_pairs.sql
done

echo "generating..."
hive -f ./create_pairs.sql >> res.txt

echo "end"
