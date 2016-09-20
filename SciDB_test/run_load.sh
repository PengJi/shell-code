:<<doc
需要修改的参数：
表名:    astronomy
主节点名: JPDB1
从节点名: worker1/worker2/worker3/worker4/worker5/worker6
doc

. ./funs.sh

# 删除旧文件
delLoadResFun

# 导入10G表
loadTable 10

# 得到表的大小
echo `date`" get table size" >> run.log
echo -e "\033[32;49;1m [get table size] \033[39;49;0m"
psql -d astronomy -f "./sql/table_size.sql" >> ./rec_load/table_size.txt

# 汇总结果
echo `date`" scp files" >> run.log
echo -e "\033[32;49;1m [scp files] \033[39;49;0m"
for k in $(seq 1 6)
do
echo `date`" worker${k} scp" >> run.log
echo -e "\033[33;49;1m [worker${k} scp] \033[39;49;0m"
ssh gpadmin@worker${k} << eof
if [ -f "/tmp/monitor${k}.txt" ]; then
   scp -o StrictHostKeyChecking=no /tmp/monitor${k}.txt gpadmin@JPDB2:/tmp 
fi
eof
done
mv /tmp/monitor.txt /tmp/monitor1.txt /tmp/monitor2.txt /tmp/monitor3.txt /tmp/monitor4.txt /tmp/monitor5.txt /tmp/monitor6.txt ./rec_load

# 操作完成
echo `date`" Load Operation Complete" >> run.log
echo -e "\033[32;49;1m [Load Operation Complete] \033[39;49;0m"
