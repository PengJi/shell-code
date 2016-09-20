:<<doc
辅助函数
doc

# 清空集群中节点的缓存
# passwd为各节点root的密码
cleanCacheFun(){
	passwd="jipeng1008"
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
echo `date`" clear node${k} cache" >> run.log
expect << exp
spawn ssh root@node${k}
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

# 清空表
# galaxylj/neighbors/photoobjall/photoprimarylj/starlj为5个表
truncateTableFun(){
	echo `date`" start truncate tables" >> run.log
	echo -e "\033[32;49;1m [truncate tables] \033[39;49;0m"
	psql -d astronomy -c "truncate galaxylj;truncate neighbors;truncate photoobjall;truncate photoprimarylj;truncate starlj;" >> run.log
	echo `date`" end truncate tables" >> run.log
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
ssh gpadmin@node${k} << eof
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
ssh gpadmin@node${k} << eof
    if [ -f "/tmp/monitor${k}.txt" ]; then
        rm /tmp/monitor${k}.txt
    fi
eof
done
}

# 导入表
# 参数可以使10、20、50、100
loadTable(){
    # 导入galaxylj
    sh ./monitor/load_monitor_start.sh
    echo `date`" loading galaxylj" >> run.log
    echo -e "\033[32;49;1m [loading galaxylj] \033[39;49;0m"
    sleep 2
    gpload -f /home/gpadmin/astronomy_data/10G/galaxylj"$1"_comma.yaml > ./rec_load/galaxylj.txt
    sleep 2
    sh ./monitor/monitor_stop.sh

    # 导入photoobjall
    sh ./monitor/load_monitor_start.sh
    echo `date`" loading photoobjall" >> run.log
    echo -e "\033[32;49;1m [loading photoobjall] \033[39;49;0m"
    sleep 2
    gpload -f /home/gpadmin/astronomy_data/10G/photoobjall"$1"_comma.yaml > ./rec_load/photoobjall.txt
    sleep 2
    sh ./monitor/monitor_stop.sh

    # 导入photoprimarylj
    sh ./monitor/load_monitor_start.sh
    echo `date`" loading photoprimarylj" >> run.log
    echo -e "\033[32;49;1m [loading photoprimarylj] \033[39;49;0m"
    sleep 2
    gpload -f /home/gpadmin/astronomy_data/10G/photoprimarylj"$1"_comma.yaml > ./rec_load/photoprimarylj.txt
    sleep 2
    sh ./monitor/monitor_stop.sh

    # 导入starlj
    sh ./monitor/load_monitor_start.sh
    echo `date`" loading starlj" >> run.log
    echo -e "\033[32;49;1m [loading starlj] \033[39;49;0m"
    sleep 2
    gpload -f /home/gpadmin/astronomy_data/10G/starlj"$1"_comma.yaml > ./rec_load/starlj.txt
    sleep 2
    sh ./monitor/monitor_stop.sh

    # 导入neighbors
    sh ./monitor/load_monitor_start.sh
    echo `date`" loading neighbors" >> run.log
    echo -e "\033[32;49;1m [loading neighbors] \033[39;49;0m"
    sleep 2
    gpload -f /home/gpadmin/astronomy_data/10G/neighbors"$1"_comma.yaml > ./rec_load/neighbors.txt
    sleep 2
    sh ./monitor/monitor_stop.sh
}


