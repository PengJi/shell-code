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
