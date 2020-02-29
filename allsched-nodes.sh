#!/bin/bash
#
# for loop to run thru servers
#
#
for node in earth-sched-1 earth-sched-2 sea-sched-1 sea-sched-2 sea-sched-3 sea-sched-4 forms-sched-dev-app-1 forms-sched-test-app-1 forms-sched-test-app-2 sched-dev-app-1 sched-test-app-1 sched-test-app-2 earth-db-2 sea-db-4 sea-db-5 sched-test-db-1 
do
echo $node;
ssh root@$node 'cat /etc/redhat-release';
ssh root@$node ' cat /proc/meminfo | grep MemTotal';
done
