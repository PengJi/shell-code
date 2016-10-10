:<<doc
程序入口
doc

. ./funs.sh

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
