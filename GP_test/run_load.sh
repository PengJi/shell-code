:<<doc
需要修改的参数：
表名:    astronomy
主节点名: JPDB2
从节点名: node1/node2/node3/node4/node5/node6
doc

# 删除旧文件
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

# 导入表
sh ./monitor/load_monitor_start.sh
echo `date`" loading galaxylj" >> run.log
echo -e "\033[32;49;1m [loading galaxylj] \033[39;49;0m"
sleep 2
gpload -f /home/gpadmin/astronomy_data/10G/galaxylj10.yaml > ./rec_load/galaxylj.txt
sleep 2
sh ./monitor/monitor_stop.sh

sh ./monitor/load_monitor_start.sh
echo `date`" loading photoobjall" >> run.log
echo -e "\033[32;49;1m [loading photoobjall] \033[39;49;0m"
sleep 2
gpload -f /home/gpadmin/astronomy_data/10G/photoobjall10.yaml > ./rec_load/photoobjall.txt
sleep 2
sh ./monitor/monitor_stop.sh

sh ./monitor/load_monitor_start.sh
echo `date`" loading photoprimarylj" >> run.log
echo -e "\033[32;49;1m [loading photoprimarylj] \033[39;49;0m"
sleep 2
gpload -f /home/gpadmin/astronomy_data/10G/photoprimarylj10.yaml > ./rec_load/photoprimarylj.txt
sleep 2
sh ./monitor/monitor_stop.sh

sh ./monitor/load_monitor_start.sh
echo `date`" loading starlj" >> run.log
echo -e "\033[32;49;1m [loading starlj] \033[39;49;0m"
sleep 2
gpload -f /home/gpadmin/astronomy_data/10G/starlj10.yaml > ./rec_load/starlj.txt
sleep 2
sh ./monitor/monitor_stop.sh

sh ./monitor/load_monitor_start.sh
echo `date`" loading neighbors" >> run.log
echo -e "\033[32;49;1m [loading neighbors] \033[39;49;0m"
sleep 2
gpload -f /home/gpadmin/astronomy_data/10G/neighbors10.yaml > ./rec_load/neighbors.txt
sleep 2
sh ./monitor/monitor_stop.sh

# 得到表的大小
echo `date`" get table size" >> run.log
echo -e "\033[32;49;1m [get table size] \033[39;49;0m"
psql -d astronomy -f "./sql/table_size.sql" >> ./rec_load/table_size.txt

# 汇总结果
# scp files
echo `date`" scp files" >> run.log
echo -e "\033[32;49;1m [scp files] \033[39;49;0m"
for k in $(seq 1 6)
do
echo `date`" node${k} scp" >> run.log
echo -e "\033[33;49;1m [node${k} scp] \033[39;49;0m"
ssh gpadmin@node${k} << eof
if [ -f "/tmp/monitor${k}.txt" ]; then
   scp -o StrictHostKeyChecking=no /tmp/monitor${k}.txt gpadmin@JPDB2:/tmp 
fi
eof
done
mv /tmp/monitor.txt /tmp/monitor1.txt /tmp/monitor2.txt /tmp/monitor3.txt /tmp/monitor4.txt /tmp/monitor5.txt /tmp/monitor6.txt ./rec_load

# 操作完成
echo `date`" Operation Complete" >> run.log
echo -e "\033[32;49;1m [Operation Complete] \033[39;49;0m"
