#!/bin/bash
#
# for loop to run thru servers
#
#
for node in sea-app-1 sea-app-2 sea-app-5 sea-app-6 stusys-test-app-1 stusys-test-app-2 websis-test-app-1 websis-test-app-2 forms-test-app-1 forms-test-app-2 sea-app-11 sea-app-12 sea-db-2 sea-db-11 sea-feed moves-test-app-1 
do
echo $node;
ssh root@$node 'cat /etc/redhat-release';
ssh root@$node ' cat /proc/meminfo | grep MemTotal';
done
