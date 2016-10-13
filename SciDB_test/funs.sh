:<<doc
辅助函数:
createDirFun --创建存放结果的目录
cleanCacheFun jipeng1008 --清空集群中各节点的缓存
delLoadResFun --删除旧的导入结果文件
delQueryResFun --删除旧的查询结果文件
delTable --删除表
loadTable 10 --导入所有表
loadGalaxyLJFun 10 --导入GalaxyLJ表
loadPhotoObjAllFun 10 --导入单个表
loadPhotoPrimaryLJFun 10 --导入单个表
loadStarLJFun 10 --导入单个表
loadneighborsFun 10 --导入单个表
queryTableFun --查询表
colResFun scidb ./rec_load --汇总结果
doc

# 创建存放结果的目录
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

# 清空集群中各个节点的缓存
# 参数:
# 集群中为各节点root的密码
cleanCacheFun(){
	passwd="$1"
	echo `date`" start clear cache" >> run.log
	echo -e "\033[32;49;1m [clear cache] \033[39;49;0m"
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
echo `date`" clear worker${k} cache" >> run.log
expect << exp
spawn ssh root@worker${k}
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
ssh scidb@worker${k} << eof
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
ssh scidb@worker${k} << eof
    if [ -f "/tmp/monitor${k}.txt" ]; then
        rm /tmp/monitor${k}.txt
    fi
eof
done
}

# 删除表
delTable(){
	echo -e "\033[32;49;1m [remove array] \033[39;49;0m"
	iquery -q "remove(GalaxyLJ)";
	iquery -q "remove(PhotoObjAll)";
	iquery -q "remove(PhotoPrimaryLJ)";
	iquery -q "remove(StarLJ)";
	iquery -q "remove(neighbors)";
}

# 导入所有表
# 参数:
# 数据大小: 10、20、50、100
loadTable(){
	# 导入GalaxyLJ
	loadGalaxyLJFun $1

	# 导入PhotoOboAll
	loadPhotoObjAllFun $1

	# 导入PhotoPrimaryLJ
	loadPhotoPrimaryLJFun $1

	# 导入StarLJ
	loadStarLJFun $1 

	# 导入neighbors
	loadneighborsFun $1
}

# 导入GalaxyLJ表
# 参数:
# 数据大小: 10、20、50、100
loadGalaxyLJFun(){
    sh ./monitor/load_monitor_start.sh
    echo `date`" loading galaxylj" >> run.log
    echo -e "\033[32;49;1m [loading galaxylj] \033[39;49;0m"
    sleep 2
    echo "load GalaxyLJ time:" > ./rec_load/galaxylj.txt
    iquery -aq "set no fetch;load(GalaxyLJ ,'/home/scidb/astronomy_data/"$1"G/GalaxyLJ"$1"_comma.csv',-2, 'CSV');" >> ./rec_load/galaxylj.txt
    sleep 2
    sh ./monitor/monitor_stop.sh
}

# 导入PhotoObjAll表
# 参数:
# 数据大小: 10、20、50、100
loadPhotoObjAllFun(){
    sh ./monitor/load_monitor_start.sh
    echo `date`" loading photoobjall" >> run.log
    echo -e "\033[32;49;1m [loading photoobjall] \033[39;49;0m"
    sleep 2
    echo "load PhotoObjAll time:" > ./rec_load/photoobjall.txt
    iquery -aq "set no fetch;load(PhotoObjAll ,'/home/scidb/astronomy_data/"$1"G/PhotoObjAll"$1"_comma.csv', -2, 'CSV');" >> ./rec_load/photoobjall.txt
    sleep 2
    sh ./monitor/monitor_stop.sh
}

# 导入PhotoPrimaryLJ表
# 参数:
# 数据大小: 10、20、50、100
loadPhotoPrimaryLJFun(){
    sh ./monitor/load_monitor_start.sh
    echo `date`" loading photoprimarylj" >> run.log
    echo -e "\033[32;49;1m [loading photoprimarylj] \033[39;49;0m"
    sleep 2
    echo "load photoprimarylj time:" > ./rec_load/photoprimarylj.txt
    iquery -aq "set no fetch;load(PhotoPrimaryLJ ,'/home/scidb/astronomy_data/"$1"G/PhotoPrimaryLJ"$1"_comma.csv', -2, 'CSV');" >> ./rec_load/photoprimarylj.txt
    sleep 2
    sh ./monitor/monitor_stop.sh
}

# 导入StarLJ表
# 参数:
# 数据大小: 10、20、50、100
loadStarLJFun(){
    sh ./monitor/load_monitor_start.sh
    echo `date`" loading starlj" >> run.log
    echo -e "\033[32;49;1m [loading starlj] \033[39;49;0m"
    sleep 2
    echo "load starlj time:" > ./rec_load/starlj.txt
    iquery -aq "set no fetch;load(StarLJ ,'/home/scidb/astronomy_data/"$1"G/StarLJ"$1"_comma.csv', -2,'CSV');" >> ./rec_load/starlj.txt
    sleep 2
    sh ./monitor/monitor_stop.sh
}

# 导入neighbors表
# 参数:
# 数据大小: 10、20、50、100
loadneighborsFun(){
    sh ./monitor/load_monitor_start.sh 
    echo `date`" loading neighbors" >> run.log
    echo -e "\033[32;49;1m [loading neighbors] \033[39;49;0m"
    sleep 2
    echo "load neighbors time:" > ./rec_load/neighbors.txt
    iquery -aq "set no fetch;load(neighbors ,'/home/scidb/astronomy_data/"$1"G/neighbors"$1"_comma.csv ,-2, 'CSV');" >> ./rec_load/neighbors.txt
    sleep 2
    sh ./monitor/monitor_stop.sh
}

# 表查询
queryTableFun(){
	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying galaxylj-1] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze SELECT objID, cModelMag_g FROm GalaxyLJ WHERE cModelMag_g between 18 and 19;" >> run.log
	echo "explain analyze SELECT objID, cModelMag_g FROm GalaxyLJ WHERE cModelMag_g between 18 and 19;" >> ./rec_query/galaxylj.txt
	iquery  -f "./sql/galaxylj-1.sql" -r /dev/null >> ./rec_query/galaxylj.txt
	sleep 2
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying photoobjall-1] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze select objID,ra,dec from PhotoObjAll where mode<=2 and ra>335 and ra<338.3 and dec>-1 and dec<1;" >> run.log
	echo "explain analyze select objID,ra,dec from PhotoObjAll where mode<=2 and ra>335 and ra<338.3 and dec>-1 and dec<1;" >> ./rec_query/photoobjall.txt
	iquery -f "./sql/photoobjall-1.sql" -r /dev/null >> ./rec_query/photoobjall.txt
	sleep 2
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	sleep 2
	echo -e "\033[32;49;1m [querying photoprimarylj-1] \033[39;49;0m"
	echo `date`" explain analyze SELECT objID, ra , dec FROM PhotoPrimaryLJ WHERE ra > 185 and ra < 185.1 AND dec > 15 and dec < 15.1;" >> run.log
	echo "explain analyze SELECT objID, ra , dec FROM PhotoPrimaryLJ WHERE ra > 185 and ra < 185.1 AND dec > 15 and dec < 15.1;" >> ./rec_query/photoprimarylj.txt
	iquery -f "./sql/photoprimarylj-1.sql" -r /dev/null >> ./rec_query/photoprimarylj.txt
	sleep 2
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying starlj] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze SELECT run, camcol, rerun, field, objID, u, g, r, i, z, ra, dec FROM StarLJ WHERE ( u - g > 2.0 or u> 22.3 ) and ( i < 19 ) and ( i > 0 ) and ( g - r > 1.0 )
 an
d ( r - i < (0.08 + 0.42 * (g - r - 0.96)) or g - r > 2.26 ) and ( i - z < 0.25 );" >> run.log
	echo "explain analyze SELECT run, camcol, rerun, field, objID, u, g, r, i, z, ra, dec FROM StarLJ WHERE ( u - g > 2.0 or u> 22.3 ) and ( i < 19 ) and ( i > 0 ) and ( g - r > 1.0 ) and ( 
r - i < (0.08 + 0.42 * (g - r - 0.96)) or g - r > 2.26 ) and ( i - z < 0.25 );" >> ./rec_query/starlj.txt
	iquery -f "./sql/starlj.sql" -r /dev/null >> ./rec_query/starlj.txt
	sleep 2
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying galaxylj-2] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze SELECT objID FROM GalaxyLJ WHERE r < 22 and extinction_r > 0.175;" >> run.log
	echo "explain analyze SELECT objID FROM GalaxyLJ WHERE r < 22 and extinction_r > 0.175;" >> ./rec_query/galaxylj.txt
	iquery -f "./sql/galaxylj-2.sql" -r /dev/null >> ./rec_query/galaxylj.txt
	sleep 2
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying photoobjall-2] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze select objID from PhotoObjAll where (r - extinction_r) < 22 and mode =1 and type =3;" >> run.log
	echo "explain analyze select objID from PhotoObjAll where (r - extinction_r) < 22 and mode =1 and type =3;" >> ./rec_query/photoobjall.txt
	iquery -f "./sql/photoobjall-2.sql" -r /dev/null >> ./rec_query/photoobjall.txt
	sleep 2
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying photoprimarylj-2] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze SELECT P.objID FROM PhotoPrimaryLJ AS P,neighbors AS N WHERE P.objID = N.objID and P.objID =N.NeighborObjID;" >> run.log
	echo "explain analyze SELECT P.objID FROM PhotoPrimaryLJ AS P,neighbors AS N WHERE P.objID = N.objID and P.objID =N.NeighborObjID;" >> ./rec_query/photoprimarylj.txt
	iquery -f "./sql/photoprimarylj-2.sql" -r /dev/null >> ./rec_query/photoprimarylj.txt
	sleep 2
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying galaxylj-3] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze SELECT colc_g, colc_r FROM GalaxyLJ WHERE (-0.642788*cx +0.766044 * cy>=0) and (-0.984808 * cx - 0.173648 * cy <0);" >> run.log
	echo "explain analyze SELECT colc_g, colc_r FROM GalaxyLJ WHERE (-0.642788*cx +0.766044 * cy>=0) and (-0.984808 * cx - 0.173648 * cy <0);" >> ./rec_query/galaxylj.txt
	iquery -f "./sql/galaxylj-3.sql" -r /dev/null >> ./rec_query/galaxylj.txt
	sleep 2
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying photoobjall-3] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze Select G.objID, G.u, G.g, G.r, G.i, G.z from (SELECT * FROM ( SELECT * FROM PhotoObjAll WHERE mode=1) as p WHERE type = 3) as G, (SELECT * FROM ( SELECT * FROM PhotoObjAll WHERE mode=1) as h) as S where G.parentID > 0 and G.parentID = S.parentID;" >> run.log
	echo "explain analyze Select G.objID, G.u, G.g, G.r, G.i, G.z from (SELECT * FROM ( SELECT * FROM PhotoObjAll WHERE mode=1) as p WHERE type = 3) as G, (SELECT * FROM ( SELECT * FROM PhotoObjAll WHERE mode=1) as h) as S where G.parentID > 0 and G.parentID = S.parentID;" >> ./rec_query/photoobjall.txt
	iquery -f "./sql/photoobjall-3.sql" -r /dev/null >> ./rec_query/photoobjall.txt
	sleep 2
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying galaxylj-4] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze  SELECT g,run,rerun,camcol,field,objID FROM GalaxyLJ WHERE ( (g <= 22) and (u - g >= -0.27) and (u - g < 0.71) and (g - r >= -0.24) and (g - r < 0.35) and (r - i >= -0.27) and (r - i < 0.57) and (i - z >= -0.35) and (i - z < 0.70) );" >> run.log
	echo "explain analyze  SELECT g,run,rerun,camcol,field,objID FROM GalaxyLJ WHERE ( (g <= 22) and (u - g >= -0.27) and (u - g < 0.71) and (g - r >= -0.24) and (g - r < 0.35) and (r - i >= -0.27) and (r - i < 0.57) and (i - z >= -0.35) and (i - z < 0.70) );" >> ./rec_query/galaxylj.txt
	iquery -f "./sql/galaxylj-4.sql" -r /dev/null >> ./rec_query/galaxylj.txt 
	sleep 2
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying photoobjall-4] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze Select G.objID, G.u, G.g, G.r, G.i, G.z from PhotoObjAll as G, StarLJ as S where G.parentID > 0 and G.parentID = S.parentID;" >> run.log
	echo "explain analyze Select G.objID, G.u, G.g, G.r, G.i, G.z from PhotoObjAll as G, StarLJ as S where G.parentID > 0 and G.parentID = S.parentID;" >> ./rec_query/photoobjall.txt
	iquery -f "./sql/photoobjall-4.sql" -r /dev/null >> ./rec_query/photoobjall.txt
	sleep 2
	sh ./monitor/monitor_stop.sh

	sh ./monitor/monitor_start.sh
	echo -e "\033[32;49;1m [querying galaxylj-5] \033[39;49;0m"
	sleep 2
	echo `date`" explain analyze SELECT COUNT(*) FROM GalaxyLJ AS g1 JOIN neighbors AS N ON g1.objID = N.objID JOIN GalaxyLJ AS g2 ON g2.objID = N.NeighborObjID WHERE g1.objID < g2.objID and N.neighborType = 3 and g1.petroRad_u > 0 and g2.petroRad_u > 0 and g1.petroRad_g > 0 and g2.petroRad_g > 0 and g1.petroRad_r > 0 and g2.petroRad_r > 0 and g1.petroRad_i > 0 and g2.petroRad_i > 0 and g1.petroRad_z > 0 and g2.petroRad_z > 0 and g1.petroRadErr_g > 0 and g2.petroRadErr_g > 0 and g1.petroMag_g>=16 and g1.petroMag_g<=21 and g2.petroMag_g>=16 and g2.petroMag_g<=21 and g1.modelMag_u > -9999 and g1.modelMag_g > -9999 and g1.modelMag_r > -9999 and g1.modelMag_i > -9999 and g1.modelMag_z > -9999 and g2.modelMag_u > -9999 and g2.modelMag_g > -9999 and g2.modelMag_r > -9999 and g2.modelMag_i > -9999 and g2.modelMag_z > -9999 and (g1.modelMag_g - g2.modelMag_g > 3 or g1.modelMag_g - g2.modelMag_g < -3) and
(g1.petroR50_r>=0.25*g2.petroR50_r AND g1.petroR50_r<=4.0*g2.petroR50_r) and (g2.petroR50_r>=0.25*g1.petroR50_r AND g2.petroR50_r<=4.0*g1.petroR50_r) and (N.distance <= (g1.petroR50_r + g2.petroR50_r));" >> run.log
	echo "explain analyze SELECT COUNT(*) FROM GalaxyLJ AS g1 JOIN neighbors AS N ON g1.objID = N.objID JOIN GalaxyLJ AS g2 ON g2.objID = N.NeighborObjID WHERE g1.objID < g2.objID and N.neighborType = 3 and g1.petroRad_u > 0 and g2.petroRad_u > 0 and g1.petroRad_g > 0 and g2.petroRad_g > 0 and g1.petroRad_r > 0 and g2.petroRad_r > 0 and g1.petroRad_i > 0 and g2.petroRad_i > 0 and g1.petroRad_z > 0 and g2.petroRad_z > 0 and g1.petroRadErr_g > 0 and g2.petroRadErr_g > 0 and g1.petroMag_g>=16 and g1.petroMag_g<=21 and g2.petroMag_g>=16 and g2.petroMag_g<=21 and g1.modelMag_u > -9999 and g1.modelMag_g > -9999 and g1.modelMag_r > -9999 and g1.modelMag_i > -9999 and g1.modelMag_z > -9999 and g2.modelMag_u > -9999 and g2.modelMag_g > -9999 and g2.modelMag_r > -9999 and g2.modelMag_i > -9999 and g2.modelMag_z > -9999 and (g1.modelMag_g - g2.modelMag_g > 3 or g1.modelMag_g - g2.modelMag_g < -3) and g1.petroR50_r>=0.25*g2.petroR50_r AND g1.petroR50_r<=4.0*g2.petroR50_r) and (g2.petroR50_r>=0.25*g1.petroR50_r AND g2.petroR50_r<=4.0*g1.petroR50_r) and (N.distance <= (g1.petroR50_r + g2.petroR50_r));" >> ./rec_query/galaxylj.txt
	#iquery -f "./sql/galaxylj-5.sql" -r /dev/null >> ./rec_query/galaxylj.txt
	sleep 2
	sh ./monitor/monitor_stop.sh
}

# 汇总结果
# 参数1：
# 主节点scidb用户密码：scidb
# 参数2：
# 要汇总的目录：./rec_load、./rec_query
colResFun(){
	echo `date`" scp files" >> run.log
	echo -e "\033[32;49;1m [scp files] \033[39;49;0m"
for k in $(seq 1 6)
do
echo `date`" worker${k} scp" >> run.log
echo -e "\033[33;49;1m [worker${k} scp] \033[39;49;0m"
ssh scidb@worker${k} << eof
if [ -f "/tmp/monitor${k}.txt" ]; then
expect << exp
	set timeout -1
	spawn scp -o StrictHostKeyChecking=no /tmp/monitor${k}.txt scidb@JPDB1:/tmp 
	expect "assword:"
	send "$1\r"
	expect eof
exp
fi
eof
done
	mv /tmp/monitor.txt /tmp/monitor1.txt /tmp/monitor2.txt /tmp/monitor3.txt /tmp/monitor4.txt /tmp/monitor5.txt /tmp/monitor6.txt $2
}

