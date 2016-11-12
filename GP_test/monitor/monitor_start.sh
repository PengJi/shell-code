:<<doc
创建monitor*文件
doc

echo -e "\033[33;49;1m [JPDB2 start] \033[39;49;0m"

ssh ${1}@JPDB2 << eof
echo "******************************************************************************************************************************" >> /tmp/monitor.txt
collectl -scmdn -oT >> /tmp/monitor.txt &
eof

for k in $(seq 1 6)
do
echo -e "\033[33;49;1m [node${k} start] \033[39;49;0m"
ssh ${1}@node${k} << eof
echo "******************************************************************************************************************************" >> /tmp/monitor${k}.txt
collectl -scmdn -oT >> /tmp/monitor${k}.txt &
eof
done

echo -e "\033[32;49;1m [monitor started] \033[39;49;0m"
