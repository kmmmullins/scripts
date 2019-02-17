#!/bin/bash
#
# for loop to run thru servers
#
#
for node in earth-app-2 earth-app-3 earth-app-4 earth-app-5 earth-app-6 stusys-dev-app-1 websis-dev-app-1 websis-dev-app-2 forms-dev-app-1 earth-vault-2 ua-qa-1 ua-qa-2 earth-db-11 stusys-dev-db-1 
do
echo $node;
ssh root@$node 'cat /etc/redhat-release';
ssh root@$node ' cat /proc/meminfo | grep MemTotal';
done
