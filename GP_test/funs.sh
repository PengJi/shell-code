:<<doc
辅助函数:
createDirFun --创建存放结果的目录
createTableFun galaxylj a --创建表
mainFun a --执行导入和查询
cleanCacheFun --清空缓存
truncateTableFun --清空表
dropTableFun --删除表
delLoadResFun --删除旧的导入结果文件
delQueryResFun --删除旧的查询结果文件
loadTable 10 --导入表
getTabeSizeFun --得到导入之后表的大小
colResFun --汇总结果
doc

# 创建目录
# rec_load 存放导入结果
# rec_query 存放查询结果
createDirFun(){
	echo `date`" mkdir" >> run.log
	echo -e "\033[32;49;1m [create dir] \033[39;49;0m"
	if [ -d "./rec_load" ]; then
    	rm -rf ./rec_load
	fi
	if [ -d "./rec_query" ]; then
    	rm -rf ./rec_query
	fi
	mkdir ./rec_load
	mkdir ./rec_query
}

# 创建表
# 参数1：
# 表名：galaxylj/photoobjall/photoprimarylj/StarLJ/neighbors
# 参数2(可选)：
# 表的类型：a/ac/ao/aoc/空(默认)
createTableFun(){
	if [ $1 == "neighbors" ]
	then
		echo `date`" create $1" >> run.log
		psql -d astronomy -f "./sql/"$1".sql"
		return
	fi

	if  [ -n "$2" ] ;then
    	if [ $2 == "a" ]
	    then
    	    echo `date`" create "$1"_a" >> run.log
			psql -d astronomy -f "./sql/"$1"_a.sql"
	    elif [ $2 == "ac" ]
    	then
        	echo `date`" create "$1"_ac" >> run.log
			psql -d astronomy -f "./sql/"$1"_ac.sql"
	    elif [ $2 == "ao" ]
    	then
        	echo `date`" create "$1"_ao" >> run.log
			psql -d astronomy -f "./sql/"$1"_ao.sql"
		elif [ $2 == "aoc" ]
		then
			echo `date`" create "$1"_aoc" >> run.log
			psql -d astronomy -f "./sql/"$1"_aoc.sql"
	    fi  
	else
        echo `date`" create $1" >> run.log
		psql -d astronomy -f "./sql/"$1".sql"
	fi
}

# 执行导入和查询
# 参数:
# 表的类型：a/ac/ao/aoc/空
mainFun(){
	if [ -n "$1" ]
	then
		mkdir ./10G_$1
		mkdir ./20G_$1
		mkdir ./50G_$1
	
		for k in $(seq 1 5 )
		do
    		./run.sh 10
	    	mv ./rec_load ./rec_load-${k}
	    	mv ./rec_query ./rec_query-${k}
		    mv ./rec_load-${k} ./10G_$1
	    	mv ./rec_query-${k} ./10G_$1
		done

		for k in $(seq 1 5 )
		do
	    	./run.sh 20
		    mv ./rec_load ./rec_load-${k}
	    	mv ./rec_query ./rec_query-${k}
		    mv ./rec_load-${k} ./20G_$1
		    mv ./rec_query-${k} ./20G_$1
		done

		for k in $(seq 1 5 )
		do
	    	./run.sh 50
		    mv ./rec_load ./rec_load-${k}
		    mv ./rec_query ./rec_query-${k}
		    mv ./rec_load-${k} ./50G_$1
		    mv ./rec_query-${k} ./50G_$1
		done
	else
        mkdir ./10G
        mkdir ./20G
        mkdir ./50G
        for k in $(seq 1 5 )
        do
            ./run.sh 10
            mv ./rec_load ./rec_load-${k}
            mv ./rec_query ./rec_query-${k}
            mv ./rec_load-${k} ./10G
            mv ./rec_query-${k} ./10G
        done
        
        for k in $(seq 1 5 )
        do
            ./run.sh 20
            mv ./rec_load ./rec_load-${k}
            mv ./rec_query ./rec_query-${k}
            mv ./rec_load-${k} ./20G
            mv ./rec_query-${k} ./20G
        done

        for k in $(seq 1 5 )
        do
            ./run.sh 50
            mv ./rec_load ./rec_load-${k}
            mv ./rec_query ./rec_query-${k}
            mv ./rec_load-${k} ./50G
            mv ./rec_query-${k} ./50G
        done
	fi
}

# 清空集群中节点的缓存
# passwd为各节点root的密码
cleanCacheFun(){
	passwd="$1"
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

# 删除表
dropTableFun(){
	echo `date`" start drop tables" >> run.log
    echo -e "\033[32;49;1m [drop tables] \033[39;49;0m"
    psql -d astronomy -c "drop table galaxylj;drop table neighbors;drop table photoobjall;drop table photoprimarylj;drop table starlj;" >> run.log
    echo `date`" end drop tables" >> run.log
}

# 删除旧的导入结果文件
delLoadResFun(){
	echo `date`" deleting monitor files" >> run.log
	echo -e "\033[33;49;1m [deleting monitor files] \033[39;49;0m"
	if [ -f "/tmp/monitor.txt" ]; then
    	rm /tmp/monitor.txt
	fi
	if [ -f "./rec_load/galaxylj.txt" ]; then
    	rm ./rec_load/galaxylj.txt
	fi
	if [ -f "./rec_load/photoobjall.txt" ]; then
    	rm ./rec_load/photoobjall.txt
	fi
	if [ -f "./rec_load/photoprimarylj.txt" ]; then
    	rm ./rec_load/photoprimarylj.txt
	fi
	if [ -f "./rec_load/starlj.txt" ]; then
    	rm ./rec_load/starlj.txt
	fi
	if [ -f "./rec_load/neighbors.txt" ]; then
    	rm ./rec_load/neighbors.txt
	fi

	for k in $(seq 1 6)
	do
ssh gpadmin@node${k} << eof
if [ -f "/tmp/monitor${k}.txt" ]; then
    rm /tmp/monitor${k}.txt
fi
eof
	done
}

# 删除旧的查询结果文件
delQueryResFun(){
	echo `date`" deleting monitor files" >> run.log
	echo -e "\033[33;49;1m [deleting monitor files] \033[39;49;0m"
	if [ -f "/tmp/monitor.txt" ]; then
    	rm /tmp/monitor.txt
	fi
	if [ -f "./rec_query/galaxylj.txt" ]; then
    	rm ./rec_query/galaxylj.txt
	fi
	if [ -f "./rec_query/photoobjall.txt" ]; then
    	rm ./rec_query/photoobjall.txt
	fi
	if [ -f "./rec_query/photoprimarylj.txt" ]; then
	    rm ./rec_query/photoprimarylj.txt
	fi
	if [ -f "./rec_query/starlj.txt" ]; then
    	rm ./rec_query/starlj.txt
	fi

for k in $(seq 1 6)
do
ssh gpadmin@node${k} << eof
    if [ -f "/tmp/monitor${k}.txt" ]; then
        rm /tmp/monitor${k}.txt
    fi
eof
done
}

# 导入表
# 参数:
# 数据大小：10、20、50、100
loadTable(){
    # 导入galaxylj
	loadGalaxyljFun $1

    # 导入photoobjall
	loadPhotoobjallFun $1

    # 导入photoprimarylj
	loadPhotoprimaryljFun $1

    # 导入starlj
	loadStarljFun $1

    # 导入neighbors
	loadneighborsFun $1
}

# 导入galaxylj表
# 参数:
# 数据大小：10、20、50、100
loadGalaxyljFun(){
	sh ./monitor/load_monitor_start.sh
	echo `date`" loading galaxylj" >> run.log
	echo -e "\033[32;49;1m [loading galaxylj] \033[39;49;0m"
	sleep 2
	gpload -f /home/gpadmin/astronomy_data/"$1"G/galaxylj"$1"_comma.yaml > ./rec_load/galaxylj.txt
	sleep 2
	sh ./monitor/monitor_stop.sh
}

# 导入photoobjall表
# 参数:
# 数据大小：10、20、50、100
loadPhotoobjallFun(){
	sh ./monitor/load_monitor_start.sh
	echo `date`" loading photoobjall" >> run.log
	echo -e "\033[32;49;1m [loading photoobjall] \033[39;49;0m"
	sleep 2
	gpload -f /home/gpadmin/astronomy_data/"$1"G/photoobjall"$1"_comma.yaml > ./rec_load/photoobjall.txt
	sleep 2
	sh ./monitor/monitor_stop.sh
}

# 导入photoprimarylj表
# 参数:
# 数据大小：10、20、50、100
loadPhotoprimaryljFun(){
	sh ./monitor/load_monitor_start.sh
	echo `date`" loading photoprimarylj" >> run.log
	echo -e "\033[32;49;1m [loading photoprimarylj] \033[39;49;0m"
	sleep 2
	gpload -f /home/gpadmin/astronomy_data/"$1"G/photoprimarylj"$1"_comma.yaml > ./rec_load/photoprimarylj.txt
	sleep 2
	sh ./monitor/monitor_stop.sh
}

# 导入starlj表
# 参数:
# 数据大小：10、20、50、100
loadStarljFun(){
	sh ./monitor/load_monitor_start.sh
	echo `date`" loading starlj" >> run.log
	echo -e "\033[32;49;1m [loading starlj] \033[39;49;0m"
	sleep 2
	gpload -f /home/gpadmin/astronomy_data/"$1"G/starlj"$1"_comma.yaml > ./rec_load/starlj.txt
	sleep 2
	sh ./monitor/monitor_stop.sh
}

# 导入neighbors表
# 参数:
# 数据大小：10、20、50、100
loadneighborsFun(){
	sh ./monitor/load_monitor_start.sh
	echo `date`" loading neighbors" >> run.log
	echo -e "\033[32;49;1m [loading neighbors] \033[39;49;0m"
	sleep 2
	gpload -f /home/gpadmin/astronomy_data/"$1"G/neighbors"$1"_comma.yaml > ./rec_load/neighbors.txt
	sleep 2
	sh ./monitor/monitor_stop.sh
}

# 得到导入后表的大小
getTabeSizeFun(){
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
}

# 查询表
queryTableFun(){
	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying galaxylj-1] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze SELECT objID, cModelMag_g FROm GalaxyLJ WHERE cModelMag_g between 18 and 19;" >> run.log
	echo "explain analyze SELECT objID, cModelMag_g FROm GalaxyLJ WHERE cModelMag_g between 18 and 19;" >> ./rec_query/galaxylj.txt
	psql -d astronomy -f "./sql/galaxylj-1.sql" >> ./rec_query/galaxylj.txt
	sleep 2
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying photoobjall-1] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze select objID,ra,dec from PhotoObjAll where mode<=2 and ra>335 and ra<338.3 and dec>-1 and dec<1;" >> run.log
	echo "explain analyze select objID,ra,dec from PhotoObjAll where mode<=2 and ra>335 and ra<338.3 and dec>-1 and dec<1;" >> ./rec_query/photoobjall.txt
	psql -d astronomy -f "./sql/photoobjall-1.sql" >> ./rec_query/photoobjall.txt
	sleep 2 
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	sleep 2
	echo -e "\033[32;49;1m [querying photoprimarylj-1] \033[39;49;0m"
	echo `date`" explain analyze SELECT objID, ra , dec FROM PhotoPrimaryLJ WHERE ra > 185 and ra < 185.1 AND dec > 15 and dec < 15.1;" >> run.log
	echo "explain analyze SELECT objID, ra , dec FROM PhotoPrimaryLJ WHERE ra > 185 and ra < 185.1 AND dec > 15 and dec < 15.1;" >> ./rec_query/photoprimarylj.txt
	psql -d astronomy -f "./sql/photoprimarylj-1.sql" >> ./rec_query/photoprimarylj.txt
	sleep 2 
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying starlj] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze SELECT run, camcol, rerun, field, objID, u, g, r, i, z, ra, dec FROM StarLJ WHERE ( u - g > 2.0 or u> 22.3 ) and ( i < 19 ) and ( i > 0 ) and ( g - r > 1.0 ) an d ( r - i < (0.08 + 0.42 * (g - r - 0.96)) or g - r > 2.26 ) and ( i - z < 0.25 );" >> run.log
echo "explain analyze SELECT run, camcol, rerun, field, objID, u, g, r, i, z, ra, dec FROM StarLJ WHERE ( u - g > 2.0 or u> 22.3 ) and ( i < 19 ) and ( i > 0 ) and ( g - r > 1.0 ) and ( r - i < (0.08 + 0.42 * (g - r - 0.96)) or g - r > 2.26 ) and ( i - z < 0.25 );" >> ./rec_query/starlj.txt
	psql -d astronomy -f "./sql/starlj.sql" >> ./rec_query/starlj.txt
	sleep 2 
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying galaxylj-2] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze SELECT objID FROM GalaxyLJ WHERE r < 22 and extinction_r > 0.175;" >> run.log
	echo "explain analyze SELECT objID FROM GalaxyLJ WHERE r < 22 and extinction_r > 0.175;" >> ./rec_query/galaxylj.txt
	psql -d astronomy -f "./sql/galaxylj-2.sql" >> ./rec_query/galaxylj.txt
	sleep 2 
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying photoobjall-2] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze select objID from PhotoObjAll where (r - extinction_r) < 22 and mode =1 and type =3;" >> run.log
	echo "explain analyze select objID from PhotoObjAll where (r - extinction_r) < 22 and mode =1 and type =3;" >> ./rec_query/photoobjall.txt
	psql -d astronomy -f "./sql/photoobjall-2.sql" >> ./rec_query/photoobjall.txt
	sleep 2 
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying photoprimarylj-2] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze SELECT P.objID FROM PhotoPrimaryLJ AS P,neighbors AS N WHERE P.objID = N.objID and P.objID =N.NeighborObjID;" >> run.log
	echo "explain analyze SELECT P.objID FROM PhotoPrimaryLJ AS P,neighbors AS N WHERE P.objID = N.objID and P.objID =N.NeighborObjID;" >> ./rec_query/photoprimarylj.txt
	psql -d astronomy -f "./sql/photoprimarylj-2.sql" >> ./rec_query/photoprimarylj.txt
	sleep 2 
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying galaxylj-3] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze SELECT colc_g, colc_r FROM GalaxyLJ WHERE (-0.642788*cx +0.766044 * cy>=0) and (-0.984808 * cx - 0.173648 * cy <0);" >> run.log
	echo "explain analyze SELECT colc_g, colc_r FROM GalaxyLJ WHERE (-0.642788*cx +0.766044 * cy>=0) and (-0.984808 * cx - 0.173648 * cy <0);" >> ./rec_query/galaxylj.txt
	psql -d astronomy -f "./sql/galaxylj-3.sql" >> ./rec_query/galaxylj.txt
	sleep 2 
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying photoobjall-3] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze Select G.objID, G.u, G.g, G.r, G.i, G.z from (SELECT * FROM ( SELECT * FROM PhotoObjAll WHERE mode=1) as p WHERE type = 3) as G, (SELECT * FROM ( SELECT * FROM PhotoObjAll WHERE mode=1) as h) as S where G.parentID > 0 and G.parentID = S.parentID;" >> run.log
	echo "explain analyze Select G.objID, G.u, G.g, G.r, G.i, G.z from (SELECT * FROM ( SELECT * FROM PhotoObjAll WHERE mode=1) as p WHERE type = 3) as G, (SELECT * FROM ( SELECT * FROM PhotoObjAll WHERE mode=1) as h) as S where G.parentID > 0 and G.parentID = S.parentID;" >> ./rec_query/photoobjall.txt
	psql -d astronomy -f "./sql/photoobjall-3.sql" >> ./rec_query/photoobjall.txt
	sleep 2 
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying galaxylj-4] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze  SELECT g,run,rerun,camcol,field,objID FROM GalaxyLJ WHERE ( (g <= 22) and (u - g >= -0.27) and (u - g < 0.71) and (g - r >= -0.24) and (g - r < 0.35) and (r - i >= -0.27) and (r - i < 0.57) and (i - z >= -0.35) and (i - z < 0.70) );" >> run.log
	echo "explain analyze  SELECT g,run,rerun,camcol,field,objID FROM GalaxyLJ WHERE ( (g <= 22) and (u - g >= -0.27) and (u - g < 0.71) and (g - r >= -0.24) and (g - r < 0.35) and (r - i >= -0.27) and (r - i < 0.57) and (i - z >= -0.35) and (i - z < 0.70) );" >> ./rec_query/galaxylj.txt
	psql -d astronomy -f "./sql/galaxylj-4.sql" >> ./rec_query/galaxylj.txt
	sleep 2 
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying photoobjall-4] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze Select G.objID, G.u, G.g, G.r, G.i, G.z from PhotoObjAll as G, StarLJ as S where G.parentID > 0 and G.parentID = S.parentID;" >> run.log
	echo "explain analyze Select G.objID, G.u, G.g, G.r, G.i, G.z from PhotoObjAll as G, StarLJ as S where G.parentID > 0 and G.parentID = S.parentID;" >> ./rec_query/photoobjall.txt
	psql -d astronomy -f "./sql/photoobjall-4.sql" >> ./rec_query/photoobjall.txt
	sleep 2 
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying galaxylj-5] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze SELECT COUNT(*) FROM GalaxyLJ AS g1 JOIN neighbors AS N ON g1.objID = N.objID JOIN GalaxyLJ AS g2 ON g2.objID = N.NeighborObjID WHERE g1.objID < g2.objID and N.neighborType = 3 and g1.petroRad_u > 0 and g2.petroRad_u > 0 and g1.petroRad_g > 0 and g2.petroRad_g > 0 and g1.petroRad_r > 0 and g2.petroRad_r > 0 and g1.petroRad_i > 0 and g2.petroRad_i > 0 and g1.petroRad_z > 0 and g2.petroRad_z > 0 and g1.petroRadErr_g > 0 and g2.petroRadErr_g > 0 and g1.petroMag_g>=16 and g1.petroMag_g<=21 and g2.petroMag_g>=16 and g2.petroMag_g<=21 and g1.modelMag_u > -9999 and g1.modelMag_g > -9999 and g1.modelMag_r > -9999 and g1.modelMag_i > -9999 and g1.modelMag_z > -9999 and g2.modelMag_u > -9999 and g2.modelMag_g > -9999 and g2.modelMag_r > -9999 and g2.modelMag_i > -9999 and g2.modelMag_z > -9999 and (g1.modelMag_g - g2.modelMag_g > 3 or g1.modelMag_g - g2.modelMag_g < -3) and (g1.petroR50_r>=0.25*g2.petroR50_r AND g1.petroR50_r<=4.0*g2.petroR50_r) and (g2.petroR50_r>=0.25*g1.petroR50_r AND g2.petroR50_r<=4.0*g1.petroR50_r) and (N.distance <= (g1.petroR50_r + g2.petroR50_r));" >> run.log
	echo "explain analyze SELECT COUNT(*) FROM GalaxyLJ AS g1 JOIN neighbors AS N ON g1.objID = N.objID JOIN GalaxyLJ AS g2 ON g2.objID = N.NeighborObjID WHERE g1.objID < g2.objID and N.neighborType = 3 and g1.petroRad_u > 0 and g2.petroRad_u > 0 and g1.petroRad_g > 0 and g2.petroRad_g > 0 and g1.petroRad_r > 0 and g2.petroRad_r > 0 and g1.petroRad_i > 0 and g2.petroRad_i > 0 and g1.petroRad_z > 0 and g2.petroRad_z > 0 and g1.petroRadErr_g > 0 and g2.petroRadErr_g > 0 and g1.petroMag_g>=16 and g1.petroMag_g<=21 and g2.petroMag_g>=16 and g2.petroMag_g<=21 and g1.modelMag_u > -9999 and g1.modelMag_g > -9999 and g1.modelMag_r > -9999 and g1.modelMag_i > -9999 and g1.modelMag_z > -9999 and g2.modelMag_u > -9999 and g2.modelMag_g > -9999 and g2.modelMag_r > -9999 and g2.modelMag_i > -9999 and g2.modelMag_z > -9999 and (g1.modelMag_g - g2.modelMag_g > 3 or g1.modelMag_g - g2.modelMag_g < -3) and (g1.petroR50_r>=0.25*g2.petroR50_r AND g1.petroR50_r<=4.0*g2.petroR50_r) and (g2.petroR50_r>=0.25*g1.petroR50_r AND g2.petroR50_r<=4.0*g1.petroR50_r) and (N.distance <= (g1.petroR50_r + g2.petroR50_r));" >> ./rec_query/galaxylj.txt
	psql -d astronomy -f "./sql/galaxylj-5.sql" >> ./rec_query/galaxylj.txt
	sleep 2 
	sh ./monitor/monitor_stop.sh
}

# 汇总结果
colResFun(){
    echo `date`" scp files" >> run.log
    echo -e "\033[32;49;1m [scp files] \033[39;49;0m"
for k in $(seq 1 6)
do
echo `date`" worker${k} scp" >> run.log
echo -e "\033[33;49;1m [node${k} scp] \033[39;49;0m"
ssh gpadmin@node${k} << eof
if [ -f "/tmp/monitor${k}.txt" ]; then
    scp -o StrictHostKeyChecking=no /tmp/monitor${k}.txt gpadmin@JPDB2:/tmp 
fi
eof
done
    mv /tmp/monitor.txt /tmp/monitor1.txt /tmp/monitor2.txt /tmp/monitor3.txt /tmp/monitor4.txt /tmp/monitor5.txt /tmp/monitor6.txt $1
}

