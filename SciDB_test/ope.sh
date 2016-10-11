:<<doc
参数及对应操作如下：
p --准备工作
t --创建表
d --删除表
l 10 --导入数据
s --查询表
ls 10 [5] --导入和查询数据
c --清空缓存
e --结尾工作
doc

. ./funs.sh

# 准备工作
# 参数：
# 操作类型：p
if [ "$1" = "p"]; then
	mkdir ./10G
	mkdir ./20G
	mkdir ./50G
fi

# 创建表
# 参数：
# 操作类型：t
if [ "$1" = "t" ]; then
	sh array.sh
fi

# 删除表
# 参数：
# 操作雷霆：d
if [ "$1" = "d" ]; then
    delTable
fi

# 导入数据
# 参数1：
# 操作类型：l
# 参数2：
# 导入的数据量：10/20/50/100
if [ "$1" = "l" ]; then
	./run_load.sh $2
fi

# 查询数据
# 参数：
# 操作类型：s
if [ "$1" = "s" ]; then
	queryTableFun
fi

# 导入和查询数据
# 参数1：
# 操作类型：ls
# 参数2：
# 数据量大小：10、20、50、100
# 参数3(可选)：
# 循环的次数：5(默认)、10
if [ "$1" = "ls" ]; then
	echo -e "\033[32;49;1m [load and query data] \033[39;49;0m"
	if [ ! -n "$3" ]; then
		for k in $(seq 1 5 )
		do
    		./run.sh $2
			mv ./rec_load ./rec_load-${k}
			mv ./rec_query ./rec_query-${k}
			mv ./rec_load-${k} ./"$2"G
			mv ./rec_query-${k} ./"$2"G
		done	
	else
		for k in $(seq 1 $3 )
		do  
			./run.sh $2
			mv ./rec_load ./rec_load-${k}
			mv ./rec_query ./rec_query-${k}
			mv ./rec_load-${k} ./"$2"G
			mv ./rec_query-${k} ./"$2"G
		done 
	fi
fi

# 清空缓存
# 参数：
# 操作类型：c
if [ "$1" = "c" ]; then
	cleanCacheFun jipeng1008
fi

# 结尾工作
if [ "$1" = "e"]; then
	# 删除表
	delTable
	# 清空缓存
	cleanCacheFun
fi
