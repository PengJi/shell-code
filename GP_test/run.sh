:<<doc
程序入口文件
运行之前需要安装:sudo yum install expect -y
需要各节点root的密码
todo
自动删除结果文件
doc

# 程序启动
echo `date`" program start" >> run.log
echo -e "\033[32;49;1m [program start] \033[39;49;0m"

# 创建目录
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

# 远程登录并清空缓存
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

# 清空表
echo `date`" start truncate tables" >> run.log
echo -e "\033[32;49;1m [truncate tables] \033[39;49;0m"
echo "[truncate tables]"
psql -d astronomy -f "./sql/truncate.sql" >> run.log
echo `date`" end truncate tables" >> run.log

# 导入表
echo -e "\033[32;49;1m [load tables] \033[39;49;0m"
echo `date`" start load tables" >> run.log
sh run_load.sh
echo `date`" end load tables" >> run.log

# 中场休息~
sleep 2

# 查询表
echo `date`" start query tables" >> run.log
echo -e "\033[32;49;1m [query tables] \033[39;49;0m"
sh run_query.sh
echo `date`" end query tables" >> run.log

echo -e "\033[32;49;1m [exection done] \033[39;49;0m"
