:<<doc
功能分解
参数及对应操作：
p --准备工作
q --清空表
d --删除表
t --创建表
l 10 --导入数据
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

# 参数1：
# 操作类型：l
# 参数2
# 表名：galaxylj/photoobjall/photoprimarylj/starlj/neighbors
# 参数3
# 数据大小：10、20、50、100
# 导入某个表
if [ "$1" = "ll" ]; then
	if [ "$2" = "galaxylj" ]; then
        if [ ! -d "./rec_load" ]; then
            mkdir ./rec_load
        fi  
        loadGalaxyljFun $3
    elif [ "$2" = "photoobjall" ]; then
        if [ ! -d "./rec_load" ]; then
            mkdir ./rec_load
        fi  
        loadPhotoobjallFun $3
    elif [ "$2" = "photoprimarylj" ]; then
        if [ ! -d "./rec_load" ]; then
            mkdir ./rec_load
        fi  
        loadPhotoprimaryljFun $3
    elif [ "$2" = "starlj" ]; then
        if [ ! -d "./rec_load" ]; then
            mkdir ./rec_load
        fi  
        loadStarljFun $3
    elif [ "$2" = "neighbors" ]; then
        if [ ! -d "./rec_load" ]; then
            mkdir ./rec_load
        fi  
        loadneighborsFun $3
    else
        echo -e "\033[31;49;1m [table not exists] \033[39;49;0m"
    fi 
fi

# 查询表
# 参数
# 操作类型：s
if [ "$1" = "s" ]; then
	queryTableFun
fi

# 导入和查询数据
# 参数
# 操作类型：ls
if [ "$1" = "ls" ]; then
fi

# 结尾工作
# 参数：
# 操作类型：e
if [ "$1" = "e" ]; then
    # 删除表
    delTable
    # 清空缓存
    cleanCacheFun
fi
