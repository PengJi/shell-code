:<<doc
功能分解
参数及对应操作：
p --准备工作
q --清空表
d --删除表
doc

. ./funs.sh

# 准备工作
# 参数：
# 操作类型：p
if [ "$1" = "p"]; then
	createDirFun
	delLoadResFun
	delQueryResFun
fi

# 清空表
# 参数：
# 操作类型：q
if [ "$1" = ""]; then
	truncateTableFun
fi

# 删除表
# 参数：
# 操作类型：d
if [ "$1" = "d"]; then
	dropTableFun
fi

# 创建表
# 参数1：
# 操作类型：t
# 参数2：
# 表名：galaxylj/photoobjall/photoprimarylj/StarLJ/neighbors
# 参数3：
# 表的类型：a/ac/ao/aoc/空(默认)
if [ "$1" = "t"]; then
	createTableFun $2 $3
fi

# 导入数据
# 参数1：
# 操作类型：l
# 参数2
# 数据大小：10、20、50、100
if [ "$1" = "l"]; then
	loadTable $2
fi

# 查询表
# 参数
# 操作类型：s
if [ "$1" = "s"]; then
	queryTableFun
fi

# 导入和查询数据
# 参数
# 操作类型：ls
if [ "$1" = "ls"]; then
	
fi

# 结尾工作
# 参数：
# 操作类型：e
if [ "$1" = "e"]; then
	
    # 删除表
    delTable
    # 清空缓存
    cleanCacheFun
fi
