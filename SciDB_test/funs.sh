:<<doc
辅助函数
doc

# 创建存放结果的目录
createDirFun(){
	echo `date`" mkdir" >> run.log
	echo -e "\033[32;49;1m [clear cache] \033[39;49;0m"
	if [ -d "./rec_load" ]; then
    	rm -rf ./rec_load
	    mkdir ./rec_load
	fi
	if [ -d "./rec_query" ]; then
    	rm -rf ./rec_query
	    mkdir ./rec_query
	fi
}

# 清空集群中各个节点的缓存
# 参数为各节点root的密码
cleanCacheFun(){
	passwd="$1"
	echo `date`" start clear cache" >> run.log
	echo -e "\033[32;49;1m [clear cache] \033[39;49;0m"
	echo -e "\033[33;49;1m [input root's password] \033[39;49;0m"
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
ssh gpadmin@worker${k} << eof
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
ssh gpadmin@worker${k} << eof
    if [ -f "/tmp/monitor${k}.txt" ]; then
        rm /tmp/monitor${k}.txt
    fi
eof
done
}

# 导入表
# 参数可以使10、20、50、100
loadTable(){
	# 导入GalaxyLJ
	sh ./monitor/load_monitor_start.sh
	echo `date`" loading galaxylj" >> run.log
	echo -e "\033[32;49;1m [loading galaxylj] \033[39;49;0m"
	sleep 2
	iquery -aq "aio_input('/home/scidb/astronomy_data/"$1"G/GalaxyLJ"$1"_comma.csv', 'num_attributes=509')" >> /dev/null
	sleep 2
	sh ./monitor/monitor_stop.sh

	# 导入PhotoOboAll
	sh ./monitor/load_monitor_start.sh
	echo `date`" loading photoobjall" >> run.log
	echo -e "\033[32;49;1m [loading photoobjall] \033[39;49;0m"
	sleep 2
	iquery -aq "aio_input('/home/scidb/astronomy_data/"$1"G/PhotoObjAll"$1"_comma.csv', 'num_attributes=509')" >> /dev/null
	sleep 2
	sh ./monitor/monitor_stop.sh

	# 导入PhotoPrimaryLJ
	sh ./monitor/load_monitor_start.sh
	echo `date`" loading photoprimarylj" >> run.log
	echo -e "\033[32;49;1m [loading photoprimarylj] \033[39;49;0m"
	sleep 2
	iquery -aq "aio_input('/home/scidb/astronomy_data/"$1"G/PhotoPrimaryLJ"$1"_comma.csv', 'num_attributes=509')" >> /dev/null
	sleep 2
	sh ./monitor/monitor_stop.sh

	# 导入StarLJ
	sh ./monitor/load_monitor_start.sh
	echo `date`" loading starlj" >> run.log
	echo -e "\033[32;49;1m [loading starlj] \033[39;49;0m"
	sleep 2
	iquery -aq "aio_input('/home/scidb/astronomy_data/"$1"G/StarLJ"$1"_comma.csv', 'num_attributes=509')" >> /dev/null
	sleep 2
	sh ./monitor/monitor_stop.sh

	# 导入neighbors
	sh ./monitor/load_monitor_start.sh 
	echo `date`" loading neighbors" >> run.log
	echo -e "\033[32;49;1m [loading neighbors] \033[39;49;0m"
	sleep 2
	iquery -aq "aio_input('/home/scidb/astronomy_data/"$1"G/neighbors"$1"_comma.csv', 'num_attributes=509')" >> /dev/null
	sleep 2
	sh ./monitor/monitor_stop.sh
}

