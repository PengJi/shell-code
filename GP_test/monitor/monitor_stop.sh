# stop collectl
echo -e "\033[31;49;1m [JPDB2 stop] \033[39;49;0m"
pgrep collectl | xargs kill -9  

for k in $(seq 1 6)
do
echo -e "\033[31;49;1m [node${k} stop] \033[39;49;0m"
ssh ${1}@node${k} << eof
  pgrep collectl | xargs kill -9
eof
done

echo -e "\033[32;49;1m [monitor stopped] \033[39;49;0m"

