:<<doc
功能分解
参数及对应操作：
p --准备工作
q --清空表
d --删除表
t --创建表
l 10 --导入数据
ll galaxylj 10 --导入某个表
s --查询表
e --结尾工作
doc

. ./funs.sh

# 准备工作
# 参数：
# 操作类型：p
if [ "$1" = "p" ]; then
	createDirFun
	delLoadResFun
	delQueryResFun
fi

# 清空表
# 参数：
# 操作类型：q
if [ "$1" = "q" ]; then
	truncateTableFun
fi

# 删除表
# 参数：
# 操作类型：d
if [ "$1" = "d" ]; then
	dropTableFun
fi

# 创建表
# 参数1：
# 操作类型：t
# 参数2：
# 表名：galaxylj/photoobjall/photoprimarylj/StarLJ/neighbors
# 参数3：
# 表的类型：a/ac/ao/aoc/空(默认)
if [ "$1" = "t" ]; then
	createTableFun $2 $3
fi

# 导入数据
# 参数1：
# 操作类型：l
# 参数2
# 数据大小：10、20、50、100
if [ "$1" = "l" ]; then
	loadTable $2
fi

# 导入某个表
# 参数1：
# 操作类型：l
# 参数2
# 表名：galaxylj/photoobjall/photoprimarylj/starlj/neighbors
# 参数3
# 数据大小：10、20、50、100
# 导入某个表
if [ "$1" = "ll" ]; then
	if [ ! -d "./rec_load" ]; then
		mkdir ./rec_load
	fi  
	if [ "$2" = "galaxylj" ]; then
        loadGalaxyljFun $3
    elif [ "$2" = "photoobjall" ]; then
        loadPhotoobjallFun $3
    elif [ "$2" = "photoprimarylj" ]; then
        loadPhotoprimaryljFun $3
    elif [ "$2" = "starlj" ]; then
        loadStarljFun $3
    elif [ "$2" = "neighbors" ]; then
        loadneighborsFun $3
    else
        echo -e "\033[31;49;1m [table not exists] \033[39;49;0m"
    fi 
fi

# 查询所有表
# 参数
# 操作类型：s
if [ "$1" = "s" ]; then
	queryTableFun
fi

# 查询单个表
# 参数1：
# 操作类型：sg
# 参数2：
# 查询：Q1/Q2/Q3/Q4/Q5/Q6/Q7/Q8/Q9/Q10/Q11/Q12
if [ "$1" = "sg"  ]; then
	if [ ! -d "./rec_load" ]; then
		mkdir ./rec_load
	fi
	if [ "$2" = "Q1" ]; then
		queryGalaxylj_1
	elif [ "$2" = "Q2" ]; then
		queryGalaxylj_2
	elif [ "$2" = "Q3" ]; then
		queryGalaxylj_3
	elif [ "$3" = "Q4" ]; then
		queryGalaxylj_4
	elif [ "$4" = "Q5" ]; then
		queryGalaxylj_5
	elif [ "$5" = "Q6" ]; then
		queryPhotoobjall_1
	elif [ "$5" = "Q7" ]; then
		queryPhotoobjall_2
	elif [ "$5" = "Q8" ]; then
		queryPhotoobjall_3
	elif [ "$5" = "Q9" ]; then
		queryPhotoobjall_4
	elif [ "$5" = "Q10" ]; then
		queryPhotoprimarylj_1
	elif [ "$5" = "Q11" ]; then
		queryPhotoprimarylj_2
	elif [ "$5" = "Q12" ]; then
		queryStarlj_1
	else
		echo -e "\033[31;49;1m [query not exists] \033[39;49;0m"
	fi
fi

# 导入和查询数据
# 参数
# 操作类型：ls
if [ "$1" = "ls" ]; then
	echo "load and query table"
fi

# 结尾工作
# 参数：
# 操作类型：e
if [ "$1" = "e" ]; then
	# 清空表
	truncateTableFun
    # 删除表
    delTable
    # 清空缓存
    cleanCacheFun
fi
