:<<doc
需要修改的参数：
表名:    astronomy
主节点名: JPDB2
从节点名: node1/node2/node3/node4/node5/node6
doc

# 包含文件
. ./funs.sh

# 删除旧文件
delLoadResFun

# 导入10G表
loadTable 10

# 得到表的大小
echo `date`" get table size" >> run.log
echo -e "\033[32;49;1m [get table size] \033[39;49;0m"
echo "galaxylj size" >> ./rec_load/table_size.txt
psql -d astronomy -c "select pg_size_pretty(pg_total_relation_size('galaxylj'));" >> ./rec_load/table_size.txt
echo "photoobjall size" >> ./rec_load/table_size.txt
psql -d astronomy -c "select pg_size_pretty(pg_total_relation_size('photoobjall'));" >> ./rec_load/table_size.txt
echo "photoprimarylj siez" >> ./rec_load/table_size.txt
psql -d astronomy -c "select pg_size_pretty(pg_total_relation_size('photoprimarylj'));" >> ./rec_load/table_size.txt
echo "starlj size" >> ./rec_load/table_size.txt 
psql -d astronomy -c "select pg_size_pretty(pg_total_relation_size('starlj'));" >> ./rec_load/table_size.txt
echo "neighbors size" >> ./rec_load/table_size.txt
psql -d astronomy -c "select pg_size_pretty(pg_total_relation_size('neighbors'));" >> ./rec_load/table_size.txt

# 汇总结果
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
echo `date`" Load Operation Complete" >> run.log
echo -e "\033[32;49;1m [Load Operation Complete] \033[39;49;0m"
