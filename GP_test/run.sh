:<<doc
程序入口文件
运行之前需要安装: sudo yum install expect -y
需要各节点root的密码
todo
自动删除结果文件
doc

. ./funs.sh

# 程序启动
echo `date`" program start" >> run.log
echo -e "\033[32;49;1m [program start] \033[39;49;0m"

# 创建目录
# rec_load 存放导入结果
# rec_query 存放查询结果
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

# 清空节点缓存缓存
cleanCacheFun

# 清空表
truncateTableFun

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

echo -e "\033[32;49;1m [program exection done] \033[39;49;0m"
