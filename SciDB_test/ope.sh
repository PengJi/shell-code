:<<doc
参数及对应操作如下：
p --准备工作
t --创建表
d --删除表
c jipeng1008 --清空缓存
l 10 --导入数据
ll GalaxyLJ 10 --导入某个表的数据
s --查询表
ls 10 [5] --导入和查询数据
c --清空缓存
e --结尾工作
doc

. ./funs.sh

prepareFun(){
	mkdir ./10G
	mkdir ./20G
	mkdir ./50G
	createDirFun
}

# 准备工作
# 参数：
# 操作类型：p
if [ "$1" = "p" ]; then
	prepareFun
fi

# 创建表
# 参数：
# 操作类型：t
if [ "$1" = "t" ]; then
	sh array.sh
fi

# 删除表
# 参数：
# 操作类型：d
if [ "$1" = "d" ]; then
    delTable
fi

# 清空各节点的缓存
# 参数1
# 操作类型：c
# 参数2
# 集群各节点的root密码
if [ "$1" = "c" ]; then
	cleanCacheFun $2
fi

# 导入所有表
# 参数1：
# 操作类型：l
# 参数2：
# 导入的数据量：10/20/50/100
if [ "$1" = "l" ]; then
	./run_load.sh $2
fi

# 导入某个表
# 参数1：
# 操作类型：ll
# 参数2：
# 导入的表名称：GalxyLJ/PhotoObjAll/PhotoPrimaryLJ/StarLJ/neighbors
# 参数3：
# 导入的数据量：10/20/50/100
if [ "$1" = "ll" ]; then
	if [ "$2" = "GalaxyLJ" ]; then
		if [ ! -d "./rec_load" ]; then
			mkdir ./rec_load
		fi
		loadGalaxyLJFun $3
	elif [ "$2" = "PhotoObjAll" ]; then
		if [ ! -d "./rec_load" ]; then
			mkdir ./rec_load
		fi
		loadPhotoObjAllFun $3
	elif [ "$2" = "PhotoPrimaryLJ" ]; then
		if [ ! -d "./rec_load" ]; then
			mkdir ./rec_load
		fi
		loadPhotoPrimaryLJFun $3
	elif [ "$2" = "StarLJ" ]; then
		if [ ! -d "./rec_load" ]; then
			mkdir ./rec_load
		fi
		loadStarLJFun $3
	elif [ "$2" = "neighbors" ]; then
		if [ ! -d "./rec_load" ]; then
			mkdir ./rec_load
		fi
		loadneighborsFun $3
	else
		echo -e "\033[31;49;1m [table not exists] \033[39;49;0m"
	fi
fi

# 查询某个查询
# 参数1
# 操作类型：sg
# 参数2
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
# 参数：
# 操作类型：e
if [ "$1" = "e" ]; then
	# 删除表
	delTable
	# 清空缓存
	cleanCacheFun
fi
