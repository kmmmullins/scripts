

SAL=/var/log/httpd/secure_access_log-6001
HOSTS=( stusys-prod-app-1 stusys-prod-app-2)

multitail -l 'ssh  root@earth-app-21 "tail -f /home/nimbus/logs/https_access_log"' -l  'ssh root@earth-app-21 "tail -f /home/nimbus/vpfforms.log"'
# multitail -l 'ssh root@stusys-prod-app-1 "tail -f /var/log/httpd/secure_access_log-6001"' -l  'ssh root@stusys-prod-app-2 "tail -f /var/log/httpd/secure_access_log-6001"'

for i in ${HOSTS[@]}
do 
echo ${HOSTS[i]}


ssh root@${HOSTS[i]} "ls -la"

done


#ssh root@${HOSTS[i]} "ls -la"



