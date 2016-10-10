:<<doc
辅助函数
doc

# 创建存放结果的目录
createDirFun(){
	echo `date`" mkdir" >> run.log
	echo -e "\033[32;49;1m [create dir] \033[39;49;0m"
	if [ -d "./rec_load" ]; then
    	rm -rf ./rec_load
	fi
	if [ -d "./rec_query" ]; then
    	rm -rf ./rec_query
	fi
	mkdir ./rec_load
	mkdir ./rec_query
}

# 清空集群中各个节点的缓存
# 参数:
# 集群中为各节点root的密码
cleanCacheFun(){
	passwd="$1"
	echo `date`" start clear cache" >> run.log
	echo -e "\033[32;49;1m [clear cache] \033[39;49;0m"
expect << exp
spawn su
expect "assword:"
send "${passwd}\r"
expect "#"
send "sync\r"
send "echo 1 > /proc/sys/vm/drop_caches\r"
send  "exit\r"
expect eof
exp

for k in $(seq 1 6)
do
echo `date`" clear worker${k} cache" >> run.log
expect << exp
spawn ssh root@worker${k}
expect "assword:"
send "${passwd}\r"
expect "#"
send "sync\r"
send "echo 1 > /proc/sys/vm/drop_caches\r"
send  "exit\r"
expect eof
exp
done
echo `date`" end clear cache" >> run.log
}

# 删除旧的导入结果文件
delLoadResFun(){
	echo `date`" deleting monitor files" >> run.log
	echo -e "\033[33;49;1m [deleting monitor files] \033[39;49;0m"
	if [ -f "/tmp/monitor.txt" ]; then
    	rm /tmp/monitor.txt
	fi
	if [ -f "./rec_load/galaxylj.txt" ]; then
    	rm ./rec_load/galaxylj.txt
	fi
	if [ -f "./rec_load/photoobjall.txt" ]; then
    	rm ./rec_load/photoobjall.txt
	fi
	if [ -f "./rec_load/photoprimarylj.txt" ]; then
    	rm ./rec_load/photoprimarylj.txt
	fi
	if [ -f "./rec_load/starlj.txt" ]; then
    	rm ./rec_load/starlj.txt
	fi
	if [ -f "./rec_load/neighbors.txt" ]; then
    	rm ./rec_load/neighbors.txt
	fi

for k in $(seq 1 6)
do
ssh scidb@worker${k} << eof
if [ -f "/tmp/monitor${k}.txt" ]; then
    rm /tmp/monitor${k}.txt
fi
eof
done
}

# 删除旧的查询结果文件
delQueryResFun(){
	echo `date`" deleting monitor files" >> run.log
	echo -e "\033[33;49;1m [deleting monitor files] \033[39;49;0m"
	if [ -f "/tmp/monitor.txt" ]; then
    	rm /tmp/monitor.txt
	fi
	if [ -f "./rec_query/galaxylj.txt" ]; then
    	rm ./rec_query/galaxylj.txt
	fi
	if [ -f "./rec_query/photoobjall.txt" ]; then
    	rm ./rec_query/photoobjall.txt
	fi
	if [ -f "./rec_query/photoprimarylj.txt" ]; then
    	rm ./rec_query/photoprimarylj.txt
	fi
	if [ -f "./rec_query/starlj.txt" ]; then
    	rm ./rec_query/starlj.txt
	fi

for k in $(seq 1 6)
do
ssh scidb@worker${k} << eof
    if [ -f "/tmp/monitor${k}.txt" ]; then
        rm /tmp/monitor${k}.txt
    fi
eof
done
}

# 删除表
delTable(){
	echo -e "\033[32;49;1m [remove array] \033[39;49;0m"
	iquery -q "remove(GalaxyLJ)";
	iquery -q "remove(PhotoObjAll)";
	iquery -q "remove(PhotoPrimaryLJ)";
	iquery -q "remove(StarLJ)";
	iquery -q "remove(neighbors)";
}

# 导入表
# 参数:
# 数据大小: 10、20、50、100
loadTable(){
	# 导入GalaxyLJ
	sh ./monitor/load_monitor_start.sh
	echo `date`" loading galaxylj" >> run.log
	echo -e "\033[32;49;1m [loading galaxylj] \033[39;49;0m"
	sleep 2
	echo "load GalaxyLJ time:" > ./rec_load/galaxylj.txt
	iquery -aq "set no fetch;load(GalaxyLJ ,'/home/scidb/astronomy_data/"$1"G/GalaxyLJ"$1"_comma.csv', -2, 'CSV');" >> ./rec_load/galaxylj.txt
	sleep 2
	sh ./monitor/monitor_stop.sh

	# 导入PhotoOboAll
	sh ./monitor/load_monitor_start.sh
	echo `date`" loading photoobjall" >> run.log
	echo -e "\033[32;49;1m [loading photoobjall] \033[39;49;0m"
	sleep 2
	echo "load PhotoObjAll time:" > ./rec_load/photoobjall.txt
	iquery -aq "set no fetch;load(PhotoObjAll ,'/home/scidb/astronomy_data/"$1"G/PhotoObjAll"$1"_comma.csv', -2, 'CSV');" >> ./rec_load/photoobjall.txt
	sleep 2
	sh ./monitor/monitor_stop.sh

	# 导入PhotoPrimaryLJ
	sh ./monitor/load_monitor_start.sh
	echo `date`" loading photoprimarylj" >> run.log
	echo -e "\033[32;49;1m [loading photoprimarylj] \033[39;49;0m"
	sleep 2
	echo "load photoprimarylj time:" > ./rec_load/photoprimarylj.txt
	iquery -aq "set no fetch;load(PhotoPrimaryLJ ,'/home/scidb/astronomy_data/"$1"G/PhotoPrimaryLJ"$1"_comma.csv', -2, 'CSV');" >> ./rec_load/photoprimarylj.txt
	sleep 2
	sh ./monitor/monitor_stop.sh

	# 导入StarLJ
	sh ./monitor/load_monitor_start.sh
	echo `date`" loading starlj" >> run.log
	echo -e "\033[32;49;1m [loading starlj] \033[39;49;0m"
	sleep 2
	echo "load starlj time:" > ./rec_load/starlj.txt
	iquery -aq "set no fetch;load(StarLJ ,'/home/scidb/astronomy_data/"$1"G/StarLJ"$1"_comma.csv', -2, 'CSV');" >> ./rec_load/starlj.txt
	sleep 2
	sh ./monitor/monitor_stop.sh

	# 导入neighbors
	sh ./monitor/load_monitor_start.sh 
	echo `date`" loading neighbors" >> run.log
	echo -e "\033[32;49;1m [loading neighbors] \033[39;49;0m"
	sleep 2
	echo "load neighbors time:" > ./rec_load/neighbors.txt
	iquery -aq "set no fetch;load(neighbors ,'/home/scidb/astronomy_data/"$1"G/neighbors"$1"_comma.csv', -2, 'CSV');" >> ./rec_load/neighbors.txt
	sleep 2
	sh ./monitor/monitor_stop.sh
}

# 汇总结果
# 参数
# 主节点scidb用户密码：scidb
# 要汇总的目录：./rec_load、./rec_query
colResFun(){
	echo `date`" scp files" >> run.log
	echo -e "\033[32;49;1m [scp files] \033[39;49;0m"
for k in $(seq 1 6)
do
echo `date`" worker${k} scp" >> run.log
echo -e "\033[33;49;1m [worker${k} scp] \033[39;49;0m"
ssh scidb@worker${k} << eof
if [ -f "/tmp/monitor${k}.txt" ]; then
expect << exp
	set timeout -1
	spawn scp -o StrictHostKeyChecking=no /tmp/monitor${k}.txt scidb@JPDB1:/tmp 
	expect "assword:"
	send "$1\r"
	expect eof
exp
fi
eof
done
	mv /tmp/monitor.txt /tmp/monitor1.txt /tmp/monitor2.txt /tmp/monitor3.txt /tmp/monitor4.txt /tmp/monitor5.txt /tmp/monitor6.txt $2
}

