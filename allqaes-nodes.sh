#!/bin/bash
#
#
# for loop to run thru servers
#
# pulled out ........ earth-cafe-2 earth-chart firesafe sky-works-1 sky-works-2 sky-vault-3 earthdrop
# also pulled out ... earth-vault earth-works-2 sea-vault-2 sky-chart skydrop sky-vault-2
#
for node in sea-app-4 sea-app-7 stusys-qa-app-1 forms-qa-app-1 forms-qa-app-2 forms-qa-app-3 sea-app-13 stusys-qa-db-1 stusys-qa-db-2 stusys-qa-db-4 websis-qa-app-1 

do
echo $node;

ssh root@$node 'cat /etc/redhat-release';
ssh root@$node ' cat /proc/meminfo | grep MemTotal';


done
