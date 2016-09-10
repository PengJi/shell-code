:<<doc
程序入口文件
todo
自动删除结果文件
doc

# 清空缓存
date >> run.log
echo "start clear cache" >> run.log
echo -e "\033[32;49;1m [clear cache] \033[39;49;0m"
echo -e "\033[33;49;1m [input root's password] \033[39;49;0m"
su -c "sync;echo 1 > /proc/sys/vm/drop_caches"
for k in $(seq 1 6)
do
echo "clear node${k} cache" >> run.log
echo -e "\033[33;49;1m [input node${k}'s root password] \033[39;49;0m"
ssh root@node${k} << eof
	sync;
	echo 1 > /proc/sys/vm/drop_caches
eof
done
date >> run.log
echo "end clear cache" >> run.log

# 清空表
date >> run.log
echo "start truncate tables" >> run.log
echo -e "\033[32;49;1m [truncate tables] \033[39;49;0m"
echo "[truncate tables]"
psql -d astronomy -f "./sql/truncate.sql" >> run.log
date >> run.log
echo "end truncate tables" >> run.log

# 导入表
date >> run.log
echo "start load tables" >> run.log
echo -e "\033[32;49;1m [load tables] \033[39;49;0m"
sh run_load.sh
end=$(date +%s.%N)  
echo "load end time is $end" >> run.log
date >> run.log
echo "end load tables" >> run.log

# 中场休息~
sleep 2

# 查询表
date >> run.log
echo "start query tables" >> run.log
echo -e "\033[32;49;1m [query tables] \033[39;49;0m"
sh run_query.sh
date >> run.log
echo "end query tables" >> run.log

echo -e "\033[32;49;1m [exection done] \033[39;49;0m"
